import '../iam/domain/auth_session.dart';
import 'application/orders_controller.dart';
import 'domain/catalog_repository.dart';
import 'infrastructure/demo_catalog_repository.dart';
import 'infrastructure/demo_order_repository.dart';
import 'infrastructure/fruitlogix_orders_api.dart';
import 'infrastructure/http_order_repository.dart';

/// Composition root of the Order Management bounded context.
///
/// [OrderManagementModule.remote] reads and places the signed-in client's
/// orders in the platform API with the user's JWT.
/// [OrderManagementModule.demo] works offline (no session, widget tests).
///
/// The catalog is demo data in both modes: the API has no products
/// endpoint yet.
class OrderManagementModule {
  OrderManagementModule._({
    required this.orders,
    required this.catalog,
    FruitLogixOrdersApi? api,
  }) : _api = api;

  factory OrderManagementModule.remote(AuthSession session) {
    final api = FruitLogixOrdersApi(token: () => session.token);
    return OrderManagementModule._(
      api: api,
      catalog: const DemoCatalogRepository(),
      orders: OrdersController(
        repository: HttpOrderRepository(api: api, clientId: session.userId),
      ),
    );
  }

  factory OrderManagementModule.demo({
    Duration latency = const Duration(milliseconds: 250),
    DateTime Function()? clock,
  }) => OrderManagementModule._(
    catalog: const DemoCatalogRepository(),
    orders: OrdersController(
      repository: DemoOrderRepository(latency: latency, clock: clock),
    ),
  );

  final OrdersController orders;
  final CatalogRepository catalog;
  final FruitLogixOrdersApi? _api;

  Future<void> start() => orders.load();

  void dispose() {
    orders.dispose();
    _api?.close();
  }
}
