import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/fruit_product.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/order_edit.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/fruitlogix_orders_api.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/http_order_repository.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _futureDate = DateTime.now().add(const Duration(days: 20));

CommercialOrder _pendingOrder() => CommercialOrder(
  id: '45',
  lines: [
    const OrderLine(
      product: FruitProduct(
        id: 1,
        name: 'Mango',
        description: '',
        category: 'Fruits',
        price: 4.50,
        stock: 100,
      ),
      quantity: 2,
    ),
  ],
  deliveryAddress: 'Lima',
  deliveryDate: _futureDate,
  status: OrderStatus.pending,
  totalAmount: 9,
);

Map<String, Object?> _serverOrder(String status) => {
  'id': 45,
  'commercialClientId': 7,
  'status': status,
  'deliveryDueDate':
      '${_futureDate.year}-${_futureDate.month.toString().padLeft(2, '0')}-${_futureDate.day.toString().padLeft(2, '0')}',
  'deliveryAddress': 'Lima',
  'totalAmount': 9,
};

void main() {
  test('PUT uses IAM JWT and exact UpdateOrderResource', () async {
    late http.Request mutation;
    final api = FruitLogixOrdersApi(
      token: () => 'session-jwt',
      baseUri: Uri.parse('https://example.invalid'),
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/orders/client/7') {
          return http.Response(jsonEncode([_serverOrder('Pending')]), 200);
        }
        if (request.method == 'GET') {
          return http.Response(jsonEncode(_serverOrder('Pending')), 200);
        }
        mutation = request;
        return http.Response(
          jsonEncode({..._serverOrder('Pending'), 'deliveryAddress': 'Av. Perú 123'}),
          200,
        );
      }),
    );
    final repo = HttpOrderRepository(api: api, clientId: 7);
    final changes = OrderUpdate(
      orderId: '45',
      deliveryDate: _futureDate,
      deliveryAddress: 'Av. Perú 123',
      notes: 'Morning',
    );
    await repo.updateOrder(_pendingOrder(), changes);
    expect(mutation.method, 'PUT');
    expect(mutation.url.path, '/api/v1/orders/45');
    expect(mutation.headers['Authorization'], 'Bearer session-jwt');
    expect(jsonDecode(mutation.body), {
      'deliveryDueDate':
          '${_futureDate.year}-${_futureDate.month.toString().padLeft(2, '0')}-${_futureDate.day.toString().padLeft(2, '0')}',
      'deliveryAddress': 'Av. Perú 123',
      'totalAmount': 9.0,
      'notes': 'Morning',
    });
  });

  test('PATCH cancel sends reason, keeping order history', () async {
    late http.Request mutation;
    final api = FruitLogixOrdersApi(
      token: () => 'jwt',
      baseUri: Uri.parse('https://example.invalid'),
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/orders/client/7') {
          return http.Response(jsonEncode([_serverOrder('Pending')]), 200);
        }
        if (request.method == 'GET') {
          return http.Response(jsonEncode(_serverOrder('Pending')), 200);
        }
        mutation = request;
        return http.Response(jsonEncode(_serverOrder('Cancelled')), 200);
      }),
    );
    final repo = HttpOrderRepository(api: api, clientId: 7);
    final result = await repo.cancelOrder(
      _pendingOrder(),
      const OrderCancellation(orderId: '45', reason: 'Duplicate'),
    );
    expect(mutation.method, 'PATCH');
    expect(mutation.url.path, '/api/v1/orders/45/cancel');
    expect(jsonDecode(mutation.body), {'reason': 'Duplicate'});
    expect(result.status, OrderStatus.cancelled);
  });

  test('404 owner list prevents writing any other client order', () async {
    var mutations = 0;
    final api = FruitLogixOrdersApi(
      token: () => 'jwt',
      baseUri: Uri.parse('https://example.invalid'),
      client: MockClient((request) async {
        if (request.url.path == '/api/v1/orders/client/7') {
          return http.Response('[]', 200);
        }
        mutations++;
        return http.Response('{}', 200);
      }),
    );
    final repo = HttpOrderRepository(api: api, clientId: 7);
    await expectLater(
      repo.cancelOrder(
        _pendingOrder(),
        const OrderCancellation(orderId: '45'),
      ),
      throwsA(isA<OrderApiException>().having(
        (e) => e.reason,
        'reason',
        OrderApiFailure.notFound,
      )),
    );
    expect(mutations, 0);
  });

  test('demo update and cancellation remain independent of HTTP', () async {
    final repo = DemoOrderRepository(latency: Duration.zero);
    final created = await repo.placeOrder(NewOrder(
      lines: _pendingOrder().lines,
      deliveryAddress: 'Lima',
      deliveryDate: _futureDate,
    ));
    final updated = await repo.updateOrder(
      created,
      OrderUpdate(
        orderId: created.id,
        deliveryDate: _futureDate,
        deliveryAddress: 'Callao',
      ),
    );
    expect(updated.deliveryAddress, 'Callao');
    final cancelled = await repo.cancelOrder(
      updated,
      OrderCancellation(orderId: updated.id, reason: 'Duplicate'),
    );
    expect(cancelled.status, OrderStatus.cancelled);
    expect((await repo.fetchOrderById(created.id))?.status,
        OrderStatus.cancelled);
  });
}
