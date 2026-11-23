import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import '../domain/membership.dart';
import '../domain/membership_repository.dart';

/// Offline data used when there is no signed-in session (widget tests and
/// design previews). The signed-in app always reads from the API.
class DemoInvoiceRepository implements InvoiceRepository {
  DemoInvoiceRepository({DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  @override
  Future<List<Invoice>> fetchMyInvoices() async {
    final today = _clock();
    DateTime day(int offset) => DateTime(today.year, today.month, today.day + offset);
    return [
      Invoice(
        id: 1042,
        clientId: 0,
        orderId: 1042,
        amount: 850.00,
        currency: 'PEN',
        dueDate: day(-4),
        status: InvoiceStatus.paid,
        paidAt: day(-6),
      ),
      Invoice(
        id: 1040,
        clientId: 0,
        orderId: 1040,
        amount: 600.00,
        currency: 'PEN',
        dueDate: day(2),
        status: InvoiceStatus.pending,
      ),
      Invoice(
        id: 1038,
        clientId: 0,
        orderId: 1038,
        amount: 850.00,
        currency: 'PEN',
        dueDate: day(-3),
        status: InvoiceStatus.pending,
      ),
    ];
  }
}

class DemoMembershipRepository implements MembershipRepository {
  @override
  Future<Membership> fetchCurrent() async => Membership.free;

  @override
  Future<ProCheckout> startProCheckout({
    required String email,
    required String name,
  }) =>
      throw UnsupportedError('Sign in to upgrade to Pro');
}
