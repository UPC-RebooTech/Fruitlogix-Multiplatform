class Payment {
  final String id;
  final String orderId;
  final String status; // PENDING, PAID, OVERDUE
  final double amount;
  final String dueDate;
  final String method;

  Payment({
    required this.id,
    required this.orderId,
    required this.status,
    required this.amount,
    required this.dueDate,
    required this.method,
  });
}