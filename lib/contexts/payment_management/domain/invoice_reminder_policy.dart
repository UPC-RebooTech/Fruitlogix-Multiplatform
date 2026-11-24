import 'invoice.dart';

/// US70 — Decides which invoice reminders must be sent, scheduled or
/// cancelled.
///
/// Pure rule, easy to unit test:
/// * Scenario 1: an unpaid invoice whose due date is within [leadDays]
///   (and not past) is reminded now. One that is further away is scheduled
///   for the day the anticipation window opens, so the reminder arrives even
///   if the app is closed.
/// * Scenario 2: a paid invoice (or one no longer owed) gets its reminder
///   cancelled and never triggers a new one.
class InvoiceReminderPolicy {
  const InvoiceReminderPolicy({required this.leadDays});

  /// Anticipation window configured by the client (days before due date).
  final int leadDays;

  static const List<int> allowedLeadDays = [1, 3, 7];
  static const int defaultLeadDays = 3;

  /// Local hour at which scheduled reminders are delivered.
  static const int deliveryHour = 9;

  ReminderPlan evaluate(Iterable<Invoice> invoices, {required DateTime today}) {
    final now = <Invoice>[];
    final later = <ScheduledReminder>[];
    final cancel = <int>{};
    for (final invoice in invoices) {
      final days = invoice.daysUntilDue(today);
      final unpaid = invoice.status == InvoiceStatus.pending;
      if (!unpaid || days < 0) {
        cancel.add(invoice.id);
      } else if (days <= leadDays) {
        now.add(invoice);
      } else {
        final windowOpens = DateTime(
          invoice.dueDate.year,
          invoice.dueDate.month,
          invoice.dueDate.day - leadDays,
          deliveryHour,
        );
        later.add(ScheduledReminder(invoice: invoice, at: windowOpens));
      }
    }
    now.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return ReminderPlan(toNotify: now, toSchedule: later, toCancel: cancel);
  }
}

class ScheduledReminder {
  const ScheduledReminder({required this.invoice, required this.at});

  final Invoice invoice;

  /// Local wall-clock time (no time zone attached).
  final DateTime at;
}

class ReminderPlan {
  const ReminderPlan({
    required this.toNotify,
    required this.toSchedule,
    required this.toCancel,
  });

  /// Invoices already inside the anticipation window: remind now.
  final List<Invoice> toNotify;

  /// Invoices still far from their due date: remind when the window opens.
  final List<ScheduledReminder> toSchedule;

  /// Invoice ids whose reminder must be withdrawn (paid, overdue, ...).
  final Set<int> toCancel;
}
