import 'package:flutter/material.dart';

import '../../../app/fruitlogix_theme.dart';
import '../application/cart_controller.dart';
import '../domain/fruit_product.dart';
import '../infrastructure/demo_catalog_repository.dart';
import '../infrastructure/in_memory_order_repository.dart';

class CustomerCatalogPage extends StatefulWidget {
  const CustomerCatalogPage({required this.onOrderCreated, super.key});

  final VoidCallback onOrderCreated;

  @override
  State<CustomerCatalogPage> createState() => _CustomerCatalogPageState();
}

class _CustomerCatalogPageState extends State<CustomerCatalogPage> {
  late final CartController _cart;
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _cart = CartController(const DemoCatalogRepository().getProducts());
  }

  @override
  void dispose() {
    _cart.dispose();
    super.dispose();
  }


  Future<void> _reviewOrder() async {
    String address = '';
    DateTime? chosenDate;

    final route = DialogRoute<({String address, DateTime deliveryDate})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, updateDialog) => AlertDialog(
          title: const Text('Confirm order'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_cart.itemCount} kg · S/ ${_cart.total.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 14),
                TextField(
                  onChanged: (value) {
                    updateDialog(() => address = value);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: chosenDate ??
                          now.add(const Duration(days: 1)),
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );

                    if (!dialogContext.mounted || picked == null) {
                      return;
                    }

                    updateDialog(() => chosenDate = picked);
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text(
                    chosenDate == null
                        ? 'Choose delivery date'
                        : '${chosenDate!.day}/${chosenDate!.month}/${chosenDate!.year}',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: chosenDate == null || address.trim().isEmpty
                  ? null
                  : () {
                Navigator.of(dialogContext).pop((
                address: address.trim(),
                deliveryDate: chosenDate!,
                ));
              },
              child: const Text('Save order'),
            ),
          ],
        ),
      ),
    );

    final result = await Navigator.of(context).push(route);

    // Wait until the dialog and its overlay are fully removed.
    await route.completed;

    if (!mounted || result == null) return;

    InMemoryOrderRepository.instance.placeOrder(
      lines: _cart.lines,
      deliveryAddress: result.address,
      deliveryDate: result.deliveryDate,
    );

    _cart.clear();
    widget.onOrderCreated();
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        final visible = _cart.products
            .where((product) => _category == 'All' || product.category == _category)
            .toList();
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text('Commercial catalog',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: FruitLogixPalette.forest,
                      )),
                  const Text('Products and prices are DEMO data'),
                  const SizedBox(height: 14),
                  Wrap(spacing: 8, children: [
                    for (final category in const ['All', 'Fruits', 'Vegetables'])
                      ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                  ]),
                  const SizedBox(height: 10),
                  for (final product in visible) ...[
                    _ProductTile(
                      product: product,
                      quantity: _cart.quantityFor(product.id),
                      onAdd: () => _cart.add(product),
                      onRemove: () => _cart.remove(product),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            ),
            if (_cart.itemCount > 0)
              SafeArea(
                top: false,
                child: Container(
                  color: FruitLogixPalette.forestSoft,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        '${_cart.itemCount} kg · S/ ${_cart.total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: _reviewOrder,
                      child: const Text('Review order'),
                    ),
                  ]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final FruitProduct product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.eco_outlined, color: FruitLogixPalette.lime),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(product.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                Text('S/ ${product.price.toStringAsFixed(2)}/${product.unit}',
                    style: const TextStyle(color: FruitLogixPalette.lime)),
              ]),
              const SizedBox(height: 8),
              Text(product.description,
                  style: const TextStyle(color: FruitLogixPalette.muted)),
              const SizedBox(height: 5),
              Text('Stock: ${product.stock} ${product.unit}',
                  style: const TextStyle(color: FruitLogixPalette.muted)),
              const SizedBox(height: 12),
              Row(children: [
                if (quantity > 0) ...[
                  IconButton.filledTonal(
                      tooltip: 'Remove ${product.name}',
                      onPressed: onRemove,
                      icon: const Icon(Icons.remove)),
                  Text('$quantity', style: const TextStyle(color: Colors.white)),
                ],
                IconButton.filledTonal(
                    tooltip: 'Add ${product.name}',
                    onPressed: quantity < product.stock ? onAdd : null,
                    icon: const Icon(Icons.add)),
              ]),
            ],
          ),
        ),
      );
}
