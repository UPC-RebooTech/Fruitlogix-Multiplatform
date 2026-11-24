import '../iam/domain/auth_session.dart';
import 'application/shipments_controller.dart';
import 'domain/shipment.dart';
import 'infrastructure/demo_shipment_repository.dart';
import 'infrastructure/fruitlogix_logistics_api.dart';
import 'infrastructure/http_shipment_repository.dart';
import 'infrastructure/phone_dialer.dart';

/// Composition root of the Logistics & Monitoring bounded context
/// (Tracking tab).
///
/// [LogisticsModule.remote] reads the deliveries of the client's orders from
/// the platform API with the user's JWT. [LogisticsModule.demo] works
/// offline (no session, widget tests).
class LogisticsModule {
  LogisticsModule._({
    required this.shipments,
    required this.dialer,
    FruitLogixLogisticsApi? api,
  }) : _api = api;

  factory LogisticsModule.remote(
    AuthSession session, {
    required ClientOrdersLookup clientOrders,
  }) {
    final api = FruitLogixLogisticsApi(token: () => session.token);
    return LogisticsModule._(
      api: api,
      dialer: const UrlLauncherPhoneDialer(),
      shipments: ShipmentsController(
        repository: HttpShipmentRepository(
          api: api,
          clientOrders: clientOrders,
        ),
      ),
    );
  }

  factory LogisticsModule.demo({
    PhoneDialer dialer = const UrlLauncherPhoneDialer(),
    Duration latency = const Duration(milliseconds: 250),
  }) => LogisticsModule._(
    dialer: dialer,
    shipments: ShipmentsController(
      repository: DemoShipmentRepository(latency: latency),
    ),
  );

  final ShipmentsController shipments;
  final PhoneDialer dialer;
  final FruitLogixLogisticsApi? _api;

  Future<void> start() => shipments.load();

  void dispose() {
    shipments.dispose();
    _api?.close();
  }
}
