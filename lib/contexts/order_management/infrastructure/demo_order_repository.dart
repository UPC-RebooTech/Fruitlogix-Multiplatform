import '../domain/commercial_order.dart';
import '../domain/order_repository.dart';
import 'demo_catalog_repository.dart';

/// Session-only demo orders (no signed-in session, widget tests). Nothing is
/// sent to the backend.
class DemoOrderRepository implements OrderRepository {
  DemoOrderRepository({
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 250),
  }) : _clock = clock ?? DateTime.now {
    final products = const DemoCatalogRepository().getProducts();
    final mango = products.firstWhere((p) => p.id == 1);
    final avocado = products.firstWhere((p) => p.id == 3);
    final now = _clock();
    DateTime day(int offset) => DateTime(now.year, now.month, now.day + offset);
    // Same orders as the demo shipment (ORD-1042) and invoices (ORD-1040).
    _orders.addAll([
      CommercialOrder(
        id: '1042',
        lines: [
          OrderLine(product: mango, quantity: 120),
          OrderLine(product: avocado, quantity: 60),
        ],
        deliveryAddress: 'Av. Nicolás Arriola 500, La Victoria',
        deliveryDate: day(0),
        createdAt: day(-3),
        status: OrderStatus.inTransit,
      ),
      CommercialOrder(
        id: '1040',
        lines: [OrderLine(product: mango, quantity: 80)],
        deliveryAddress: 'Av. Nicolás Arriola 500, La Victoria',
        deliveryDate: day(2),
        createdAt: day(-1),
        status: OrderStatus.preparing,
      ),
    ]);
  }

  final DateTime Function() _clock;
  final Duration latency;
  final List<CommercialOrder> _orders = [];
  int _nextId = 1043;

  @override
  Future<List<CommercialOrder>> fetchMyOrders() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return List.of(_orders);
  }

  @override
  Future<CommercialOrder> placeOrder(NewOrder order) async {
    final problem = order.validate(today: _clock());
    if (problem != null) throw ArgumentError('Invalid order: $problem');
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final created = CommercialOrder(
      id: '${_nextId++}',
      lines: List.unmodifiable(order.lines),
      deliveryAddress: order.deliveryAddress.trim(),
      deliveryDate: order.deliveryDate,
      createdAt: _clock(),
      status: OrderStatus.pending,
      notes: (order.notes?.trim().isEmpty ?? true) ? null : order.notes!.trim(),
    );
    _orders.add(created);
    return created;
  }
}
