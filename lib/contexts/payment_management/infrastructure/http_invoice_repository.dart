import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import 'fruitlogix_payments_api.dart';
import 'invoice_json_parser.dart';

/// Invoices from the platform API, filtered to the signed-in client.
///
/// The backend identifies the Commercial Client with the IAM user id
/// (`Invoice.clientId == user.id`).
class HttpInvoiceRepository implements InvoiceRepository {
  HttpInvoiceRepository({required this.api, required this.clientId});

  final FruitLogixPaymentsApi api;
  final int clientId;

  @override
  Future<List<Invoice>> fetchMyInvoices() async {
    final body = await api.getInvoices();
    try {
      return InvoiceJsonParser.parseList(body)
          .where((invoice) => invoice.clientId == clientId)
          .toList();
    } on FormatException {
      throw const PaymentApiException(PaymentApiFailure.unexpectedResponse);
    }
  }
}
