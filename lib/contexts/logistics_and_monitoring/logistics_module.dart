import '../iam/domain/auth_session.dart';
import 'application/arrivals_controller.dart';
import 'application/shipments_controller.dart';
import 'domain/geofence.dart';
import 'domain/lot_timeline.dart';
import 'domain/reception_repository.dart';
import 'domain/shipment.dart';
import 'infrastructure/arrival_notifier.dart';
import 'infrastructure/arrivals_store.dart';
import 'infrastructure/demo_lot_records.dart';
import 'infrastructure/demo_shipment_repository.dart';
import 'infrastructure/fruitlogix_logistics_api.dart';
import 'infrastructure/http_shipment_repository.dart';
import 'infrastructure/phone_dialer.dart';
import 'infrastructure/reception_repositories.dart';
import 'infrastructure/warehouse_locator.dart';

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
    required this.arrivals,
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
      // The platform has no warehouse geofence yet: kept on the phone (US65).
      arrivals: ArrivalsController(
        store: SharedPreferencesArrivalsStore(userId: session.userId),
        notifier: LocalArrivalNotifier.isSupported
            ? LocalArrivalNotifier()
            : NoopArrivalNotifier(),
        locator: const GeolocatorWarehouseLocator(),
      ),
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
    WarehouseZone? zone,
    ArrivalNotifier? notifier,
    WarehouseLocator locator = const FixedWarehouseLocator(demoWarehouse),
    Duration latency = const Duration(milliseconds: 250),
  }) => LogisticsModule._(
    dialer: dialer,
    lots: DemoLotRecords(),
    arrivals: ArrivalsController(
      store: InMemoryArrivalsStore(zone: zone),
      notifier: notifier ?? NoopArrivalNotifier(),
      locator: locator,
    ),
    shipments: ShipmentsController(
      repository: DemoShipmentRepository(latency: latency),
      reception: reception ?? DemoReceptionRepository(latency: latency),
    ),
  );

  final ShipmentsController shipments;
  final PhoneDialer dialer;

  /// Harvest and quality records of each order's lot (US72).
  final LotRecordSource lots;

  /// Warehouse zone and arrivals list (US65).
  final ArrivalsController arrivals;
  final FruitLogixLogisticsApi? _api;

  /// Demo warehouse in Lima, ~1.4 km from the demo truck.
  static const GeoPoint demoWarehouse = GeoPoint(-12.0600, -77.0300);

  /// Loads the deliveries and records the ones inside the warehouse zone.
  Future<void> refresh() async {
    await shipments.load();
    if (shipments.status == ShipmentsStatus.ready) {
      await arrivals.check(shipments.shipments);
    }
  }

  Future<void> start() async {
    await arrivals.load();
    await refresh();
  }

  void dispose() {
    shipments.dispose();
    arrivals.dispose();
    _api?.close();
  }
}
