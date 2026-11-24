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
      final List<CommercialOrder> fetched = [
        ...await _repository.fetchMyOrders(),
      ]..sort(_newestFirst);
      _orders = List<CommercialOrder>.unmodifiable(fetched);
      _status = OrdersStatus.ready;
    } catch (error) {
      _error = error;
      _status = OrdersStatus.failure;
    }
    _notify();
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
