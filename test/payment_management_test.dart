import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/application/invoice_reminder_service.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/application/membership_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/domain/financial_balance.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/domain/invoice.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/domain/invoice_reminder_policy.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/domain/membership.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/domain/membership_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/infrastructure/invoice_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/payment_management/infrastructure/shared_preferences_reminder_settings_store.dart';

final DateTime today = DateTime(2026, 11, 22);

Invoice invoice(int id, double amount, int dueInDays, InvoiceStatus status) =>
    Invoice(
      id: id,
      clientId: 7,
      amount: amount,
      currency: 'PEN',
      dueDate: DateTime(today.year, today.month, today.day + dueInDays),
      status: status,
    );

void main() {
  group('US36 · Scenario 2 — format normalization', () {
    test('statuses in different text formats', () {
      for (final raw in ['PAID', 'paid', 'Pagado', ' PAGADA ', 'Succeeded', 1, '1']) {
        expect(InvoiceJsonParser.parseStatus(raw), InvoiceStatus.paid, reason: '$raw');
      }
      for (final raw in ['PENDING', 'pending', 'Pendiente', 'UNPAID', 'pending_payment', 0]) {
        expect(InvoiceJsonParser.parseStatus(raw), InvoiceStatus.pending, reason: '$raw');
      }
      for (final raw in ['OVERDUE', 'Vencido', 'vencida', 'LATE', 2]) {
        expect(InvoiceJsonParser.parseStatus(raw), InvoiceStatus.overdue, reason: '$raw');
      }
      expect(InvoiceJsonParser.parseStatus('Reembolsado'), InvoiceStatus.refunded);
      expect(InvoiceJsonParser.parseStatus('FAILED'), InvoiceStatus.failed);
    });

    test('unknown status falls back to the payment date', () {
      expect(InvoiceJsonParser.parseStatus('???'), InvoiceStatus.pending);
      expect(
        InvoiceJsonParser.parseStatus(null, paidAt: DateTime(2026)),
        InvoiceStatus.paid,
      );
    });

    test('amounts as numbers and text', () {
      expect(InvoiceJsonParser.parseAmount(600), 600);
      expect(InvoiceJsonParser.parseAmount('1450.50'), 1450.5);
      expect(InvoiceJsonParser.parseAmount('1,450.00'), 1450);
      expect(InvoiceJsonParser.parseAmount('1.450,00'), 1450);
      expect(InvoiceJsonParser.parseAmount('S/ 600'), 600);
      expect(InvoiceJsonParser.parseAmount('S/. 1,450.00'), 1450);
      expect(InvoiceJsonParser.parseAmount('600,5'), 600.5);
      expect(InvoiceJsonParser.parseAmount({'amount': 12.5}), 12.5);
      expect(InvoiceJsonParser.parseAmount('abc'), isNull);
    });

    test('calendar dates keep their day', () {
      expect(InvoiceJsonParser.parseDate('2026-11-30'), DateTime(2026, 11, 30));
      expect(InvoiceJsonParser.parseDate('2026-11-30T00:00:00Z'), DateTime(2026, 11, 30));
      expect(InvoiceJsonParser.parseDate('30/11/2026'), DateTime(2026, 11, 30));
    });

    test('API list with mixed formats keeps every invoice', () {
      final invoices = InvoiceJsonParser.parseList([
        {'id': 1, 'clientId': 7, 'totalAmount': 600, 'currency': 'PEN', 'dueDate': '2026-11-30', 'status': 'PENDING'},
        {'Id': '2', 'client_id': 7, 'total_amount': '850.00', 'due_date': '2026-11-10', 'status': 'pagado'},
        {'id': 3, 'clientId': 7, 'totalAmount': '1,000.00', 'dueDate': '2026-11-01', 'status': 'Pending'},
        {'clientId': 7, 'totalAmount': 1}, // not identifiable -> skipped
      ]);
      expect(invoices.map((i) => i.id), [1, 2, 3]);

      final balance = FinancialBalance.fromInvoices(invoices, today: today);
      expect(balance.totalBilled, 2450);
      expect(balance.accumulatedDebt, 1600);
      expect(balance.overdueAmount, 1000); // pending but already due
      expect(balance.paidAmount, 850);
      expect(balance.overdueCount, 1);
    });
  });

  group('US70 — reminder policy', () {
    const policy = InvoiceReminderPolicy(leadDays: 3);

    test('Scenario 1: unpaid invoice inside the window is reminded', () {
      final plan = policy.evaluate([
        invoice(1, 600, 2, InvoiceStatus.pending),
        invoice(2, 300, 10, InvoiceStatus.pending),
      ], today: today);
      expect(plan.toNotify.map((i) => i.id), [1]);
      expect(plan.toSchedule.single.invoice.id, 2);
      expect(plan.toSchedule.single.at, DateTime(2026, 11, 29, 9));
    });

    test('Scenario 2: paid invoice is cancelled and never reminded', () {
      final plan = policy.evaluate([
        invoice(1, 600, 2, InvoiceStatus.paid),
      ], today: today);
      expect(plan.toNotify, isEmpty);
      expect(plan.toSchedule, isEmpty);
      expect(plan.toCancel, {1});
    });
  });

  group('US70 — reminder service', () {
    late _FakeNotifier notifier;
    late InvoiceReminderService service;

    setUp(() {
      notifier = _FakeNotifier();
      service = InvoiceReminderService(
        notifier: notifier,
        store: InMemoryReminderSettingsStore(),
      )..textBuilder = (i) => (title: i.code, body: '${i.amount}');
    });

    test('sends a push once per invoice and cancels it when paid', () async {
      final pending = invoice(5, 600, 1, InvoiceStatus.pending);
      await service.sync([pending], today: today);
      await service.sync([pending], today: today);
      expect(notifier.shown, [5]);
      expect(service.upcoming.single.id, 5);

      await service.sync([pending.copyWith(status: InvoiceStatus.paid)], today: today);
      expect(notifier.cancelled, contains(5));
      expect(service.upcoming, isEmpty);
      expect(notifier.shown, [5]);
    });

    test('disabled reminders send nothing', () async {
      await service.updateSettings(enabled: false);
      await service.sync([invoice(5, 600, 1, InvoiceStatus.pending)], today: today);
      expect(notifier.shown, isEmpty);
    });
  });

  group('US30 — Pro membership', () {
    test('Pro only after the backend (webhook) confirms the plan', () async {
      final repository = _FakeMembershipRepository(confirmAfter: 2);
      final controller = MembershipController(
        repository: repository,
        gateway: _FakeGateway(const PaymentSheetCompleted()),
        pollInterval: Duration.zero,
      );
      await controller.upgradeToPro(email: 'a@b.pe', name: 'Ana');
      expect(controller.stage, ProCheckoutStage.success);
      expect(controller.isPro, isTrue);
    });

    test('closing the Payment Sheet keeps the free plan', () async {
      final controller = MembershipController(
        repository: _FakeMembershipRepository(confirmAfter: 0),
        gateway: _FakeGateway(const PaymentSheetCanceled()),
        pollInterval: Duration.zero,
      );
      await controller.upgradeToPro(email: 'a@b.pe', name: 'Ana');
      expect(controller.stage, ProCheckoutStage.canceled);
      expect(controller.isPro, isFalse);
    });

    test('webhook not received yet -> pending confirmation', () async {
      final controller = MembershipController(
        repository: _FakeMembershipRepository(confirmAfter: 99),
        gateway: _FakeGateway(const PaymentSheetCompleted()),
        pollInterval: Duration.zero,
        maxPolls: 3,
      );
      await controller.upgradeToPro(email: 'a@b.pe', name: 'Ana');
      expect(controller.stage, ProCheckoutStage.pendingConfirmation);
      expect(controller.isPro, isFalse);
    });
  });
}

class _FakeNotifier implements InvoiceReminderNotifier {
  final shown = <int>[];
  final cancelled = <int>[];

  @override
  Future<bool> ensureReady() async => true;

  @override
  Future<void> showNow(Invoice invoice, ReminderText text) async => shown.add(invoice.id);

  @override
  Future<void> schedule(Invoice invoice, ReminderText text, DateTime at) async {}

  @override
  Future<void> cancel(int invoiceId) async => cancelled.add(invoiceId);
}

class _FakeMembershipRepository implements MembershipRepository {
  _FakeMembershipRepository({required this.confirmAfter});

  /// Number of polls before the webhook "arrives".
  final int confirmAfter;
  int _polls = 0;
  bool _paid = false;

  @override
  Future<Membership> fetchCurrent() async {
    if (_paid && ++_polls >= confirmAfter) {
      return Membership(plan: MembershipPlan.pro, activatedAt: DateTime(2026));
    }
    return Membership.free;
  }

  @override
  Future<ProCheckout> startProCheckout({required String email, required String name}) async {
    _paid = true;
    return const ProCheckout(
      clientSecret: 'pi_123_secret_abc',
      customerId: 'cus_1',
      amount: 29,
      currency: 'USD',
    );
  }
}

class _FakeGateway implements PaymentSheetGateway {
  _FakeGateway(this.result);
  final PaymentSheetResult result;

  @override
  bool get isAvailable => true;

  @override
  Future<PaymentSheetResult> present(ProCheckout checkout) async => result;
}
