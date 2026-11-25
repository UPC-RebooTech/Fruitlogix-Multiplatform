import 'package:http/http.dart' as http;

import '../iam/domain/auth_session.dart';
import 'application/financial_overview_controller.dart';
import 'application/invoice_reminder_service.dart';
import 'application/membership_controller.dart';
import 'infrastructure/demo_payment_repositories.dart';
import 'infrastructure/fruitlogix_payments_api.dart';
import 'infrastructure/http_invoice_repository.dart';
import 'infrastructure/http_membership_repository.dart';
import 'infrastructure/local_invoice_reminder_notifier.dart';
import 'infrastructure/shared_preferences_reminder_settings_store.dart';
import 'infrastructure/stripe_payment_sheet_gateway.dart';

/// Composition root of the Payment Management bounded context.
///
/// [PaymentManagementModule.remote] talks to the platform API with the
/// signed-in user's JWT. [PaymentManagementModule.demo] works offline (no
/// session, widget tests).
class PaymentManagementModule {
  PaymentManagementModule._({
    required this.overview,
    required this.reminders,
    required this.membership,
    FruitLogixPaymentsApi? api,
  }) : _api = api;

  factory PaymentManagementModule.remote(AuthSession session, {http.Client? client}) {
    final api = FruitLogixPaymentsApi(token: () => session.token, client: client);
    final reminders = InvoiceReminderService(
      notifier: LocalInvoiceReminderNotifier.isSupported
          ? LocalInvoiceReminderNotifier()
          : NoopInvoiceReminderNotifier(),
      store: SharedPreferencesReminderSettingsStore(userId: session.userId),
    );
    return PaymentManagementModule._(
      api: api,
      reminders: reminders,
      overview: FinancialOverviewController(
        repository: HttpInvoiceRepository(api: api, clientId: session.userId),
        reminders: reminders,
      ),
      membership: MembershipController(
        repository: HttpMembershipRepository(api: api),
        gateway: const StripePaymentSheetGateway(),
      ),
    );
  }

  factory PaymentManagementModule.demo({DateTime Function()? clock}) {
    final reminders = InvoiceReminderService(
      notifier: NoopInvoiceReminderNotifier(),
      store: InMemoryReminderSettingsStore(),
    );
    return PaymentManagementModule._(
      reminders: reminders,
      overview: FinancialOverviewController(
        repository: DemoInvoiceRepository(clock: clock),
        reminders: reminders,
        clock: clock,
      ),
      membership: MembershipController(
        repository: DemoMembershipRepository(),
        gateway: const UnavailablePaymentSheetGateway(),
      ),
    );
  }

  final FinancialOverviewController overview;
  final InvoiceReminderService reminders;
  final MembershipController membership;
  final FruitLogixPaymentsApi? _api;

  /// Loads the balance, the reminder settings and the plan in parallel.
  Future<void> start() async {
    await Future.wait([
      reminders.loadSettings(),
      overview.load(),
      membership.refresh(),
    ]);
  }

  void dispose() {
    overview.dispose();
    reminders.dispose();
    membership.dispose();
    _api?.close();
  }
}
