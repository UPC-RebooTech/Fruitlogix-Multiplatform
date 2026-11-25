import 'package:flutter/foundation.dart';

import '../domain/catalog_repository.dart';
import '../domain/fruit_product.dart';

enum CatalogStatus { idle, loading, ready, failure }

/// Products of the catalog tab (US07): `GET /products?available=true` with a
/// session, demo products without one.
class CatalogController extends ChangeNotifier {
  CatalogController({required CatalogRepository repository})
    : _repository = repository;

  final CatalogRepository _repository;

  CatalogStatus _status = CatalogStatus.idle;
  List<FruitProduct> _products = const [];
  Object? _error;
  Future<void>? _inFlight;
  bool _disposed = false;

  CatalogStatus get status => _status;
  List<FruitProduct> get products => _products;
  Object? get error => _error;

  /// Concurrent calls share the same request.
  Future<void> load() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    _status = CatalogStatus.loading;
    _error = null;
    _notify();
    try {
      _products = List.unmodifiable(await _repository.fetchProducts());
      _status = CatalogStatus.ready;
    } catch (error) {
      _error = error;
      _status = CatalogStatus.failure;
    }
    _notify();
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
