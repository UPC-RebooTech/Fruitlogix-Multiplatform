import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';
import '../domain/order_repository.dart';

enum OrdersStatus { idle, loading, ready, failure }

/// Loads the client's orders once and shares them with Home, Orders and
/// Incidents; places new orders from the catalog.
///
/// Loading never blocks navigation: screens render at once with a loader.
class OrdersController extends ChangeNotifier {
  OrdersController({required OrderRepository repository})
    : _repository = repository;

  final OrderRepository _repository;

  OrdersStatus _status = OrdersStatus.idle;
  List<CommercialOrder> _orders = const [];
  Object? _error;
  bool _submitting = false;
  Future<void>? _inFlight;
  bool _disposed = false;

  OrdersStatus get status => _status;
  Object? get error => _error;
  bool get submitting => _submitting;

  /// Newest first.
  List<CommercialOrder> get orders => _orders;

  bool get hasData =>
      _status == OrdersStatus.ready ||
      (_status == OrdersStatus.loading && _orders.isNotEmpty);

  List<CommercialOrder> get activeOrders =>
      _orders.where((order) => order.status.isActive).toList(growable: false);

  /// US07 — finished orders (delivered, cancelled, rejected), newest first.
  List<CommercialOrder> get history =>
      _orders.where((order) => !order.status.isActive).toList(growable: false);

  Map<int, String> _producerNames = const {};

  /// Producer id → name: `producerName` of the orders first, then
  /// `GET /producers` (empty if neither is available).
  Map<int, String> get producerNames => {
    ..._producerNames,
    for (final order in _orders)
      if (order.producerId != null && order.producerName != null)
        order.producerId!: order.producerName!,
  };

  int get activeCount => activeOrders.length;
  int get inTransitCount =>
      _orders.where((order) => order.status == OrderStatus.inTransit).length;

  /// Concurrent calls share the same request.
  Future<void> load() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    _status = OrdersStatus.loading;
    _error = null;
    _notify();
    try {
      final names = _loadProducerNames();
      final List<CommercialOrder> fetched = [
        ...await _repository.fetchMyOrders(),
      ]..sort(_newestFirst);
      _orders = List<CommercialOrder>.unmodifiable(fetched);
      _producerNames = await names;
      _status = OrdersStatus.ready;
    } catch (error) {
      _error = error;
      _status = OrdersStatus.failure;
    }
    _notify();
  }

  /// Producer names are a nice-to-have: without them the filter shows
  /// "Producer #id", so a failure here never breaks the orders.
  Future<Map<int, String>> _loadProducerNames() async {
    try {
      return await _repository.fetchProducerNames();
    } catch (_) {
      return _producerNames;
    }
  }

  /// Places [order]; on success it is added at the top of the list.
  /// Rethrows the repository error so the catalog can show it.
  Future<CommercialOrder> placeOrder(NewOrder order) async {
    final problem = order.validate();
    if (problem != null) throw ArgumentError('Invalid order: $problem');
    _submitting = true;
    _notify();
    try {
      final created = await _repository.placeOrder(order);
      _orders = List.unmodifiable([
        created,
        ..._orders.where((o) => o.id != created.id),
      ]);
      if (_status != OrdersStatus.ready) _status = OrdersStatus.ready;
      return created;
    } finally {
      _submitting = false;
      _notify();
    }
  }

  static int _newestFirst(CommercialOrder a, CommercialOrder b) {
    final byCreation = (b.createdAt ?? b.deliveryDate).compareTo(
      a.createdAt ?? a.deliveryDate,
    );
    if (byCreation != 0) return byCreation;
    return (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
