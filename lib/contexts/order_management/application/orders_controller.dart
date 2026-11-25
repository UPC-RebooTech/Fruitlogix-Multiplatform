
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';
import '../domain/order_edit.dart';
import '../domain/order_mutation_repository.dart';
import '../domain/order_repository.dart';
import 'order_history_filter.dart';
import 'supplier_performance.dart';

enum OrdersStatus { idle, loading, ready, failure }

/// Orders of the authenticated Commercial Client.
///
/// Domain validation happens before any write. The remote repository is
/// responsible for server-side authorization, current status and persistence.
class OrdersController extends ChangeNotifier {
  OrdersController({required OrderRepository repository})
      : _repository = repository;

  final OrderRepository _repository;

  OrdersStatus _status = OrdersStatus.idle;
  List<CommercialOrder> _orders = const [];
  Map<int, String> _producerNames = const {};
  Object? _error;
  Object? _mutationError;
  bool _submitting = false;
  bool _mutating = false;
  String? _mutatingOrderId;
  Future<void>? _inFlight;
  Timer? _refreshTimer;
  bool _disposed = false;

  OrdersStatus get status => _status;
  Object? get error => _error;
  Object? get mutationError => _mutationError;
  bool get submitting => _submitting;
  bool get mutating => _mutating;
  String? get mutatingOrderId => _mutatingOrderId;
  bool get supportsOrderMutations => _repository is OrderMutationRepository;

  /// Newest first. Exposes an immutable snapshot.
  List<CommercialOrder> get orders => _orders;

  bool get hasData =>
      _status == OrdersStatus.ready ||
          (_status == OrdersStatus.loading && _orders.isNotEmpty);

  List<CommercialOrder> get activeOrders =>
      _orders.where((order) => order.status.isActive).toList(growable: false);

  List<CommercialOrder> get history =>
      _orders.where((order) => !order.status.isActive).toList(growable: false);

  List<CommercialOrder> filteredHistory(OrderHistoryFilter filter) =>
      filter.apply(history);

  SupplierPerformanceReport supplierPerformance({DateTime? today}) =>
      measureSupplierPerformance(_orders, today: today ?? DateTime.now());

  Map<int, String> get producerNames => {
    ..._producerNames,
    for (final order in _orders)
      if (order.producerId != null && order.producerName != null)
        order.producerId!: order.producerName!,
  };

  int get activeCount => activeOrders.length;
  int get inTransitCount =>
      _orders.where((order) => order.status == OrderStatus.inTransit).length;

  CommercialOrder? findById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  /// Concurrent callers share a single request. A failing refresh retains
  /// the last successfully loaded list for offline/error presentation.
  Future<void> load() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    if (_disposed || _submitting || _mutating) return;
    _status = OrdersStatus.loading;
    _error = null;
    _notify();
    try {
      final namesFuture = _loadProducerNames();
      final fetched = [...await _repository.fetchMyOrders()]..sort(_newestFirst);
      final names = await namesFuture;
      if (_disposed) return;
      _orders = List<CommercialOrder>.unmodifiable(fetched);
      _producerNames = names;
      _status = OrdersStatus.ready;
    } catch (error) {
      if (_disposed) return;
      _error = error;
      _status = OrdersStatus.failure;
    }
    _notify();
  }

  Future<Map<int, String>> _loadProducerNames() async {
    try {
      return await _repository.fetchProducerNames();
    } catch (_) {
      return _producerNames;
    }
  }

  /// Validates and submits a new order. A failed request does not create a
  /// local order and allows the catalog to preserve the shopper's cart.
  Future<CommercialOrder> placeOrder(NewOrder order) async {
    final problem = order.validate();
    if (problem != null) throw ArgumentError('Invalid order: $problem');
    _ensureAvailable();
    _submitting = true;
    _mutationError = null;
    _notify();
    try {
      final created = await _repository.placeOrder(order);
      if (!_disposed) {
        _orders = List.unmodifiable([
          created,
          ..._orders.where((item) => item.id != created.id),
        ]);
        _status = OrdersStatus.ready;
        _notify();
      }
      return created;
    } catch (error) {
      _mutationError = error;
      rethrow;
    } finally {
      _submitting = false;
      _notify();
    }
  }

  /// Edits only fields supported by UpdateOrderResource (address/date/notes).
  /// The repository reloads the order from the server to enforce its status.
  Future<CommercialOrder> updateOrder(
      CommercialOrder current,
      OrderUpdate changes,
      ) async {
    final problem = changes.validateAgainst(current);
    if (problem != null) throw StateError('Invalid order update: $problem');
    final mutations = _requireMutations();
    _ensureAvailable();
    _startMutation(current.id);
    try {
      final saved = await mutations.updateOrder(current, changes);
      if (!_disposed) _upsert(saved);
      return saved;
    } catch (error) {
      _mutationError = error;
      rethrow;
    } finally {
      _finishMutation();
    }
  }

  /// Cancels a pending order; it remains in history after the server confirms
  /// status Cancelled. No local state is changed if the API rejects it.
  Future<CommercialOrder> cancelOrder(
      CommercialOrder current,
      OrderCancellation cancellation,
      ) async {
    final problem = cancellation.validateAgainst(current);
    if (problem != null) throw StateError('Invalid cancellation: $problem');
    final mutations = _requireMutations();
    _ensureAvailable();
    _startMutation(current.id);
    try {
      final saved = await mutations.cancelOrder(current, cancellation);
      if (!_disposed) _upsert(saved);
      return saved;
    } catch (error) {
      _mutationError = error;
      rethrow;
    } finally {
      _finishMutation();
    }
  }

  /// Fetches one previously listed order to update its progress. This does
  /// not fabricate statuses or convert a transient HTTP error into success.
  Future<CommercialOrder?> refreshOrderById(String id) async {
    final mutations = _requireMutations();
    _ensureAvailable();
    final updated = await mutations.fetchOrderById(id);
    if (!_disposed && updated != null) _upsert(updated);
    return updated;
  }

  /// Periodic polling, not a push or WebSocket stream. Call only while the
  /// Orders screen is visible; stop it when leaving the screen/background.
  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (interval <= Duration.zero) {
      throw ArgumentError.value(interval, 'interval', 'Must be positive');
    }
    if (_disposed) throw StateError('OrdersController has been disposed');
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(interval, (_) {
      if (!_disposed && !_submitting && !_mutating && _inFlight == null) {
        load();
      }
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  OrderMutationRepository _requireMutations() {
    final repository = _repository;
    if (repository is! OrderMutationRepository) {
      throw StateError('This repository does not support order changes');
    }
    return repository;
  }

  void _ensureAvailable() {
    if (_disposed) throw StateError('OrdersController has been disposed');
    if (_submitting || _mutating) {
      throw StateError('Another order operation is in progress');
    }
  }

  void _startMutation(String id) {
    _mutating = true;
    _mutatingOrderId = id;
    _mutationError = null;
    _notify();
  }

  void _finishMutation() {
    _mutating = false;
    _mutatingOrderId = null;
    _notify();
  }

  void _upsert(CommercialOrder updated) {
    _orders = List.unmodifiable([
      ..._orders.where((order) => order.id != updated.id),
      updated,
    ]..sort(_newestFirst));
    _status = OrdersStatus.ready;
    _notify();
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
    stopAutoRefresh();
    _disposed = true;
    super.dispose();
  }
}
