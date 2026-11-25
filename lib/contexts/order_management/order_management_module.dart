import 'package:http/http.dart' as http;

import '../iam/domain/auth_session.dart';
import 'application/orders_controller.dart';
import 'application/catalog_controller.dart';
import 'infrastructure/demo_catalog_repository.dart';
import 'infrastructure/http_catalog_repository.dart';
import 'infrastructure/demo_order_repository.dart';
import 'infrastructure/fruitlogix_orders_api.dart';
import 'infrastructure/http_order_repository.dart';

/// Composition root of the Order Management bounded context.
///
/// [OrderManagementModule.remote] reads and places the signed-in client's
/// orders in the platform API with the user's JWT.
/// [OrderManagementModule.demo] works offline (no session, widget tests).
///
/// The catalog comes from `GET /products` with a session.
class OrderManagementModule {
  OrderManagementModule._({
    required this.orders,
    required this.catalog,
    FruitLogixOrdersApi? api,
  }) : _api = api;

  factory OrderManagementModule.remote(AuthSession session, {http.Client? client}) {
    final api = FruitLogixOrdersApi(token: () => session.token, client: client);
    return OrderManagementModule._(
      api: api,
      catalog: CatalogController(repository: HttpCatalogRepository(api: api)),
      orders: OrdersController(
        repository: HttpOrderRepository(api: api, clientId: session.userId),
      ),
    );
  }

  factory OrderManagementModule.demo({
    Duration latency = const Duration(milliseconds: 250),
    DateTime Function()? clock,
  }) => OrderManagementModule._(
    catalog: CatalogController(repository: const DemoCatalogRepository()),
    orders: OrdersController(
      repository: DemoOrderRepository(latency: latency, clock: clock),
    ),
  );

  final OrdersController orders;
  /// Catalog products (US07).
  final CatalogController catalog;
  final FruitLogixOrdersApi? _api;

  Future<void> start() => Future.wait([orders.load(), catalog.load()]);

  void dispose() {
    orders.dispose();
    catalog.dispose();
    _api?.close();
  }
}
