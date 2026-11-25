
import '../domain/commercial_order.dart';
import '../domain/order_edit.dart';
import '../domain/order_mutation_repository.dart';
import 'demo_catalog_repository.dart';

/// Session-only demo orders (no signed-in session, widget tests). Nothing is
/// sent to the backend.
class DemoOrderRepository implements OrderMutationRepository {
  DemoOrderRepository({
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 250),
  }) : _clock = clock ?? DateTime.now {
    final products = const DemoCatalogRepository().getProducts();
    final mango = products.firstWhere((p) => p.id == 1);
    final avocado = products.firstWhere((p) => p.id == 3);
    final grapes = products.firstWhere((p) => p.id == 5);
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
        producerId: 1,
      ),
      // History (US07): finished orders.
      CommercialOrder(
        id: '1036',
        lines: [OrderLine(product: avocado, quantity: 150)],
        deliveryAddress: 'Av. Nicolás Arriola 500, La Victoria',
        deliveryDate: day(-9),
        createdAt: day(-14),
        status: OrderStatus.delivered,
        producerId: 1,
        completedAt: day(-9), // on time
      ),
      CommercialOrder(
        id: '1031',
        lines: [OrderLine(product: grapes, quantity: 40)],
        deliveryAddress: 'Av. Nicolás Arriola 500, La Victoria',
        deliveryDate: day(-20),
        createdAt: day(-24),
        status: OrderStatus.cancelled,
        notes: 'Cancelled: duplicated order',
      ),
      CommercialOrder(
        id: '1027',
        lines: [
          OrderLine(product: mango, quantity: 200),
          OrderLine(product: grapes, quantity: 30),
        ],
        deliveryAddress: 'Jr. Ucayali 120, Cercado de Lima',
        deliveryDate: day(-38),
        createdAt: day(-42),
        status: OrderStatus.delivered,
        producerId: 2,
        completedAt: day(-36), // two days late
      ),
    ]);
  }

  /// Demo producers (same ids as above).
  static const Map<int, String> producerNames = {
    1: 'Agrícola San José',
    2: 'Fundo El Mango',
  };

  @override
  Future<Map<int, String>> fetchProducerNames() async => producerNames;

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

  @override
  Future<CommercialOrder?> fetchOrderById(String orderId) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    for (final order in _orders) {
      if (order.id == orderId) return order;
    }
    return null;
  }

  @override
  Future<CommercialOrder> updateOrder(
    CommercialOrder current,
    OrderUpdate changes,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final index = _orders.indexWhere((order) => order.id == current.id);
    if (index < 0) throw StateError('Order does not exist');
    final updated = changes.applyTo(_orders[index], today: _clock());
    _orders[index] = updated;
    return updated;
  }

  @override
  Future<CommercialOrder> cancelOrder(
    CommercialOrder current,
    OrderCancellation changes,
  ) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final index = _orders.indexWhere((order) => order.id == current.id);
    if (index < 0) throw StateError('Order does not exist');
    final cancelled = changes.applyTo(_orders[index]);
    _orders[index] = cancelled;
    return cancelled;
  }
}
