import 'invoice.dart';

/// Port for reading the signed-in client's invoices.
abstract interface class InvoiceRepository {
  /// Invoices of the current Commercial Client.
  Future<List<Invoice>> fetchMyInvoices();
}
