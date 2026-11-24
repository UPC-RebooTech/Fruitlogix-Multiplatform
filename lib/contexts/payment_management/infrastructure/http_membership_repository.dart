import '../domain/membership.dart';
import '../domain/membership_repository.dart';
import 'fruitlogix_payments_api.dart';
import 'invoice_json_parser.dart';

class HttpMembershipRepository implements MembershipRepository {
  HttpMembershipRepository({required this.api});

  final FruitLogixPaymentsApi api;

  static const double proMonthlyPrice = 29.00;

  @override
  Future<Membership> fetchCurrent() async {
    final Object? body;
    try {
      body = await api.getMyMembership();
    } on PaymentApiException catch (error) {
      // Endpoint not deployed yet: the user is treated as free.
      if (error.reason == PaymentApiFailure.notFound) return Membership.free;
      rethrow;
    }
    if (body is! Map) return Membership.free;
    final plan = (body['plan'] ?? '').toString().trim().toUpperCase();
    return Membership(
      plan: plan == 'PRO' ? MembershipPlan.pro : MembershipPlan.free,
      activatedAt: InvoiceJsonParser.parseDate(body['activatedAt'], keepTime: true),
    );
  }

  @override
  Future<ProCheckout> startProCheckout({
    required String email,
    required String name,
  }) async {
    final body = await api.subscribe(email: email, name: name, planType: 'PRO');
    if (body is! Map) {
      throw const PaymentApiException(PaymentApiFailure.unexpectedResponse);
    }
    final secret = body['clientSecret'];
    if (secret is! String || secret.isEmpty) {
      throw const PaymentApiException(PaymentApiFailure.unexpectedResponse);
    }
    return ProCheckout(
      clientSecret: secret,
      customerId: (body['customerId'] ?? '').toString(),
      amount: InvoiceJsonParser.parseAmount(body['amount']) ?? proMonthlyPrice,
      currency: (body['currency'] ?? 'USD').toString().toUpperCase(),
    );
  }
}
