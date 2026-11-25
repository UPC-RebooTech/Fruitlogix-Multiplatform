import 'invoice.dart';

/// US36 — Financial summary of the Commercial Client shown on the dashboard.
///
/// Value object derived from the client's invoices. Every invoice counts:
/// statuses and amounts are normalized before they get here, so no metric
/// ends up in zero because of a format error.
class FinancialBalance {
  const FinancialBalance({
    required this.totalBilled,
    required this.accumulatedDebt,
    required this.overdueAmount,
    required this.paidAmount,
    required this.outstandingCount,
    required this.overdueCount,
  });

  static const FinancialBalance empty = FinancialBalance(
    totalBilled: 0,
    accumulatedDebt: 0,
    overdueAmount: 0,
    paidAmount: 0,
    outstandingCount: 0,
    overdueCount: 0,
  );

  /// Everything invoiced to the client (saldo total).
  final double totalBilled;

  /// Pending + overdue (deuda acumulada).
  final double accumulatedDebt;

  /// Part of the debt already past its due date.
  final double overdueAmount;
  final double paidAmount;
  final int outstandingCount;
  final int overdueCount;

  /// Refunded or failed invoices are not owed and are not counted as billed.
  factory FinancialBalance.fromInvoices(
    Iterable<Invoice> invoices, {
    required DateTime today,
  }) {
    var total = 0.0, debt = 0.0, overdue = 0.0, paid = 0.0;
    var outstandingCount = 0, overdueCount = 0;
    for (final raw in invoices) {
      final invoice = raw.withEffectiveStatus(today);
      switch (invoice.status) {
        case InvoiceStatus.paid:
          total += invoice.amount;
          paid += invoice.amount;
        case InvoiceStatus.pending:
          total += invoice.amount;
          debt += invoice.amount;
          outstandingCount++;
        case InvoiceStatus.overdue:
          total += invoice.amount;
          debt += invoice.amount;
          overdue += invoice.amount;
          outstandingCount++;
          overdueCount++;
        case InvoiceStatus.failed:
        case InvoiceStatus.refunded:
          break;
      }
    }
    return FinancialBalance(
      totalBilled: _round(total),
      accumulatedDebt: _round(debt),
      overdueAmount: _round(overdue),
      paidAmount: _round(paid),
      outstandingCount: outstandingCount,
      overdueCount: overdueCount,
    );
  }

  /// Avoids binary noise such as 1449.9999999 when adding cents.
  static double _round(double value) => (value * 100).roundToDouble() / 100;
}
