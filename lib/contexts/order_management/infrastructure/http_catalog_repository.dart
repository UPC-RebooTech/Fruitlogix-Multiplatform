import '../domain/catalog_repository.dart';
import '../domain/fruit_product.dart';
import 'fruitlogix_orders_api.dart';

/// Products of the platform catalog: `GET /products?available=true` (active
/// products with stock, of every producer).
class HttpCatalogRepository implements CatalogRepository {
  HttpCatalogRepository({required this.api});

  final FruitLogixOrdersApi api;

  @override
  Future<List<FruitProduct>> fetchProducts() async {
    final body = await api.getProducts(available: true);
    try {
      return parseList(body);
    } on FormatException {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
  }

  static List<FruitProduct> parseList(Object? body) {
    final list = switch (body) {
      List() => body,
      Map() => body['data'] ?? body['items'],
      null => const [],
      _ => null,
    };
    if (list is! List) throw const FormatException('Products: not a list');
    return [
      for (final item in list)
        if (item is Map) ?parse(item),
    ];
  }

  /// `ProductResource`; null when it cannot be sold (inactive, no id).
  static FruitProduct? parse(Map<dynamic, dynamic> json) {
    final id = _int(json['id']);
    final name = _text(json['name']);
    if (id == null || name == null || json['isActive'] == false) return null;
    final variety = _text(json['variety']);
    final fruitType = _text(json['fruitType']);
    return FruitProduct(
      id: id,
      name: name,
      description:
          _text(json['description']) ??
          [?fruitType, ?variety].join(' · '),
      category: fruitType ?? '',
      price: _double(json['unitPrice']) ?? 0,
      // Whole kilograms: the app sells by the kg.
      stock: (_double(json['availableKg']) ?? 0).floor(),
      minQuantity: ((_double(json['minOrderKg']) ?? 1).ceil()).clamp(1, 1 << 30),
      producerId: _int(json['producerId']),
      producerName: _text(json['producerName']),
      imageUrl: _text(json['imageUrl']),
    );
  }

  static String? _text(Object? raw) {
    final value = raw is String ? raw.trim() : '';
    return value.isEmpty ? null : value;
  }

  static int? _int(Object? raw) => switch (raw) {
    int() => raw,
    num() => raw.toInt(),
    String() => int.tryParse(raw.trim()),
    _ => null,
  };

  static double? _double(Object? raw) => switch (raw) {
    num() => raw.toDouble(),
    String() => double.tryParse(raw.trim()),
    _ => null,
  };
}
