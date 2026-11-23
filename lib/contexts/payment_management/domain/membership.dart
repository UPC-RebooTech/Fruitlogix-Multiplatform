/// SaaS plan of the user (US30 / TS17).
enum MembershipPlan { free, pro }

class Membership {
  const Membership({required this.plan, this.activatedAt});

  static const Membership free = Membership(plan: MembershipPlan.free);

  final MembershipPlan plan;
  final DateTime? activatedAt;

  bool get isPro => plan == MembershipPlan.pro;
}

/// Data the native Payment Sheet needs, created by the backend
/// (`POST /api/v1/payments/subscribe`). Contains no card data.
class ProCheckout {
  const ProCheckout({
    required this.clientSecret,
    required this.customerId,
    required this.amount,
    required this.currency,
  });

  final String clientSecret;
  final String customerId;
  final double amount;
  final String currency;
}
