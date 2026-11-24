import '../domain/reception_repository.dart';
import '../domain/shipment.dart';
import 'fruitlogix_logistics_api.dart';

/// `POST /api/v1/orders/{orderId}/reception` (US35).
class HttpReceptionRepository implements ReceptionRepository {
  HttpReceptionRepository({required this.api});

  final FruitLogixLogisticsApi api;

  /// The API requires an integer rating; 0 means "not rated" (US35 · the
  /// rating is optional).
  static const int notRated = 0;

  static Map<String, Object?> toBody(ReceptionReport report) {
    final comment = report.comment?.trim() ?? '';
    return {
      'rating': report.rating ?? notRated,
      'comment': comment.isEmpty ? null : comment,
      'hasIncidence': report.hasIncidence,
    };
  }

  @override
  Future<void> confirm(
    DeliveryShipment shipment,
    ReceptionReport report,
  ) async {
    if (!report.isValid) throw ArgumentError('Rating must be 1 to 5');
    final orderNumber = shipment.orderNumber;
    if (orderNumber == null) {
      throw ArgumentError('Delivery ${shipment.id} has no platform order id');
    }
    await api.confirmReception(orderNumber, toBody(report));
  }
}

/// Offline reception (demo deliveries, widget tests).
class DemoReceptionRepository implements ReceptionRepository {
  DemoReceptionRepository({this.latency = const Duration(milliseconds: 250)});

  final Duration latency;

  /// Reports received, for tests.
  final List<ReceptionReport> confirmed = [];

  @override
  Future<void> confirm(
    DeliveryShipment shipment,
    ReceptionReport report,
  ) async {
    if (!report.isValid) throw ArgumentError('Rating must be 1 to 5');
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    confirmed.add(report);
  }
}
