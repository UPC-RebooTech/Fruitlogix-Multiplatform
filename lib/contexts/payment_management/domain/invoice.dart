/// Billing state of an invoice, already normalized (see
/// `InvoiceStatusParser`). The backend may send it in several text formats.
enum InvoiceStatus { pending, paid, overdue, failed, refunded }

/// Invoice issued to the Commercial Client (Payment Management BC).
///
/// Pure domain model: no Flutter, JSON or HTTP dependencies.
class Invoice {
  const Invoice({
    required this.id,
    required this.clientId,
    required this.amount,
    required this.currency,
    required this.dueDate,
    required this.status,
    this.orderId,
    this.issuedAt,
    this.paidAt,
  });

  final int id;
  final int clientId;
  final int? orderId;
  final double amount;

  /// ISO 4217 code, e.g. `PEN`.
  final String currency;

  /// Calendar day (time is ignored).
  final DateTime dueDate;
  final InvoiceStatus status;
  final DateTime? issuedAt;
  final DateTime? paidAt;

  /// Human code shown in the app, e.g. `INV-0042`.
  String get code => 'INV-${id.toString().padLeft(4, '0')}';

  String? get orderCode =>
      orderId == null ? null : 'ORD-${orderId.toString().padLeft(4, '0')}';

  bool get isPaid => status == InvoiceStatus.paid;

  /// Still owed by the client (pending or overdue).
  bool get isOutstanding =>
      status == InvoiceStatus.pending || status == InvoiceStatus.overdue;

  /// Whole days from [today] to the due date (negative when already due).
  int daysUntilDue(DateTime today) =>
      _dateOnly(dueDate).difference(_dateOnly(today)).inDays;

  /// A pending invoice whose due date has passed is overdue, even if the
  /// backend has not updated its status yet.
  Invoice withEffectiveStatus(DateTime today) {
    if (status == InvoiceStatus.pending && daysUntilDue(today) < 0) {
      return copyWith(status: InvoiceStatus.overdue);
    }
    return this;
  }

  Invoice copyWith({InvoiceStatus? status}) => Invoice(
        id: id,
        clientId: clientId,
        orderId: orderId,
        amount: amount,
        currency: currency,
        dueDate: dueDate,
        status: status ?? this.status,
        issuedAt: issuedAt,
        paidAt: paidAt,
      );

  // UTC midnight so daylight-saving shifts never change the day count.
  static DateTime _dateOnly(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
}
