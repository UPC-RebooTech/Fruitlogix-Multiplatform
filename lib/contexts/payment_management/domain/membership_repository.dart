import 'membership.dart';

/// Port for the user's SaaS membership.
abstract interface class MembershipRepository {
  /// Current plan as confirmed by the backend (the webhook is the authority).
  Future<Membership> fetchCurrent();

  /// Asks the backend for a Stripe PaymentIntent for the Pro plan.
  Future<ProCheckout> startProCheckout({
    required String email,
    required String name,
  });
}
