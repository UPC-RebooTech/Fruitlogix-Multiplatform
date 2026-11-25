import 'package:http/http.dart' as http;

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
import 'infrastructure/platform_arrivals.dart';
import 'infrastructure/reception_repositories.dart';
import 'infrastructure/traceability_json_parser.dart';
import 'infrastructure/warehouse_locator.dart';

/// Composition root of the Logistics & Monitoring bounded context
/// (Tracking tab).
///
/// [LogisticsModule.remote] reads the deliveries of the client's orders from
/// the platform API with the user's JWT. [LogisticsModule.demo] works
/// offline (no session, widget tests).
/// `GET /orders/{id}/traceability` (US72).
class HttpTraceabilitySource implements TraceabilitySource {
  HttpTraceabilitySource({required this.api});

  final FruitLogixLogisticsApi api;

  @override
  Future<LotTimeline> timelineFor({
    required int orderId,
    required String orderCode,
    String? productSummary,
  }) async => TraceabilityJsonParser.parse(
    await api.getTraceability(orderId),
    orderCode: orderCode,
    productSummary: productSummary,
  );
}

class LogisticsModule {
  LogisticsModule._({
    required this.shipments,
    required this.dialer,
    required this.lots,
    required this.arrivals,
    this.traceability,
    FruitLogixLogisticsApi? api,
  }) : _api = api;

  factory LogisticsModule.remote(
    AuthSession session, {
    required ClientOrdersLookup clientOrders,
    http.Client? client,
  }) {
    final api = FruitLogixLogisticsApi(token: () => session.token, client: client);
    return LogisticsModule._(
      api: api,
      dialer: const UrlLauncherPhoneDialer(),
      // US72: the platform assembles the timeline of each order.
      lots: const NoLotRecords(),
      traceability: HttpTraceabilitySource(api: api),
      // US65: the warehouse is in the client's profile and the platform
      // detects the arrivals; the phone only remembers which it notified.
      arrivals: ArrivalsController(
        store: PlatformArrivalsStore(
          api: api,
          arrivals: SharedPreferencesArrivalsStore(userId: session.userId),
        ),
        detector: PlatformArrivalDetector(api: api),
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

  /// The platform's order timeline (US72); null in the demo, which
  /// assembles it from [lots] and the other contexts.
  final TraceabilitySource? traceability;

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
