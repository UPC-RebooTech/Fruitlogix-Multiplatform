import '../domain/commercial_order.dart';
import '../domain/order_edit.dart';
import 'order_json_parser.dart';

/// JSON payloads kept out of the domain entities and controllers.
abstract final class OrderMutationJson {
  /// UpdateOrderResource defined in the provided Swagger contract.
  /// Order items cannot be changed with this endpoint.
  static Map<String, Object?> update(
    CommercialOrder existing,
    OrderUpdate changes,
  ) => {
    'deliveryDueDate': OrderJsonParser.formatApiDate(changes.deliveryDate),
    'deliveryAddress': changes.deliveryAddress.trim(),
    'totalAmount': _money(existing.total),
    'notes': changes.notes?.trim(),
  };

  /// CancelOrderResource defined in the provided Swagger contract.
  static Map<String, Object?> cancel(OrderCancellation changes) => {
    'reason': changes.reason?.trim(),
  };

  static double _money(double amount) =>
      (amount * 100).roundToDouble() / 100;
}
