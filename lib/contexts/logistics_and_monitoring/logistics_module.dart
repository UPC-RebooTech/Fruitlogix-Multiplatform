import '../iam/domain/auth_session.dart';
import 'application/shipments_controller.dart';
import 'domain/lot_timeline.dart';
import 'domain/reception_repository.dart';
import 'domain/shipment.dart';
import 'infrastructure/demo_lot_records.dart';
import 'infrastructure/demo_shipment_repository.dart';
import 'infrastructure/fruitlogix_logistics_api.dart';
import 'infrastructure/http_shipment_repository.dart';
import 'infrastructure/phone_dialer.dart';
import 'infrastructure/reception_repositories.dart';

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
    required this.lots,
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
      // Orders are not linked to harvest lots in the platform yet (US72).
      lots: const NoLotRecords(),
      shipments: ShipmentsController(
        repository: HttpShipmentRepository(
          api: api,
          clientOrders: clientOrders,
        ),
        reception: HttpReceptionRepository(api: api),
      ),
    );
  }

  factory LogisticsModule.demo({
    PhoneDialer dialer = const UrlLauncherPhoneDialer(),
    ReceptionRepository? reception,
    Duration latency = const Duration(milliseconds: 250),
  }) => LogisticsModule._(
    dialer: dialer,
    lots: DemoLotRecords(),
    shipments: ShipmentsController(
      repository: DemoShipmentRepository(latency: latency),
      reception: reception ?? DemoReceptionRepository(latency: latency),
    ),
  );

  final ShipmentsController shipments;
  final PhoneDialer dialer;

  /// Harvest and quality records of each order's lot (US72).
  final LotRecordSource lots;
  final FruitLogixLogisticsApi? _api;

  Future<void> start() => shipments.load();

  void dispose() {
    shipments.dispose();
    _api?.close();
  }
}
