import '../domain/payment.dart';

class InMemoryPaymentRepository {
  final List<Payment> payments = [
    Payment(
      id: 'INV-1042',
      orderId: 'ORD-1042',
      status: 'PENDING',
      amount: 850.00,
      dueDate: '18 November 2026',
      method: 'Bank transfer · Reference pending',
    ),
    Payment(
      id: 'INV-1032',
      orderId: 'ORD-1032',
      status: 'PAID',
      amount: 600.00,
      dueDate: '10 November 2026',
      method: 'Direct deposit · Confirmed',
    ),
  ];

  double get pendingBalance => payments
      .where((p) => p.status == 'PENDING')
      .fold(0.0, (sum, item) => sum + item.amount);
}