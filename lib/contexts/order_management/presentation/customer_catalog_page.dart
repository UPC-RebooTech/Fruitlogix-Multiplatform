import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/cart_controller.dart';
import '../domain/fruit_product.dart';
import '../infrastructure/demo_catalog_repository.dart';
import '../infrastructure/in_memory_order_repository.dart';

/// Category filters. [key] matches `FruitProduct.category` (domain data);
/// the label comes from the ARB files.
enum _CatalogFilter {
  all(null),
  fruits('Fruits'),
  vegetables('Vegetables');

  const _CatalogFilter(this.key);

  final String? key;

  bool matches(FruitProduct product) => key == null || product.category == key;

  String label(AppLocalizations l10n) => switch (this) {
        _CatalogFilter.all => l10n.catalogFilterAll,
        _CatalogFilter.fruits => l10n.catalogFilterFruits,
        _CatalogFilter.vegetables => l10n.catalogFilterVegetables,
      };
}

class CustomerCatalogPage extends StatefulWidget {
  const CustomerCatalogPage({required this.onOrderCreated, super.key});

  final VoidCallback onOrderCreated;

  @override
  State<CustomerCatalogPage> createState() => _CustomerCatalogPageState();
}

class _CustomerCatalogPageState extends State<CustomerCatalogPage> {
  late final CartController _cart;
  _CatalogFilter _filter = _CatalogFilter.all;

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
    final result = await showModalBottomSheet<_OrderReviewResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _OrderReviewSheet(
        quantity: _cart.itemCount,
        total: _cart.total,
      ),
    );
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
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _cart,
      builder: (context, _) {
        final visible = _cart.products.where(_filter.matches).toList();
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  CosechaSpace.screenMargin,
                  CosechaSpace.md,
                  CosechaSpace.screenMargin,
                  CosechaSpace.md,
                ),
                children: [
                  CosechaPageHeader(
                    title: l10n.catalogTitle,
                    subtitle: l10n.catalogSubtitle,
                  ),
                  const SizedBox(height: CosechaSpace.sm),
                  Wrap(
                    spacing: CosechaSpace.xs,
                    runSpacing: CosechaSpace.xs,
                    children: [
                      for (final filter in _CatalogFilter.values)
                        CosechaFilterChip(
                          label: filter.label(l10n),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                    ],
                  ),
                  const SizedBox(height: CosechaSpace.sm),
                  if (visible.isEmpty)
                    CosechaEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.catalogEmptyTitle,
                      message: l10n.catalogEmptyMessage,
                    ),
                  for (final product in visible) ...[
                    _ProductCard(
                      product: product,
                      quantity: _cart.quantityFor(product.id),
                      onAdd: () => _cart.add(product),
                      onRemove: () => _cart.remove(product),
                    ),
                    const SizedBox(height: CosechaSpace.xs),
                  ],
                ],
              ),
            ),
            if (_cart.itemCount > 0)
              _CartPanel(
                summary: l10n.cartSummary(
                  _cart.itemCount,
                  formatSoles(_cart.total),
                ),
                onReview: _reviewOrder,
              ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    return CosechaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CosechaIconBox(icon: Icons.eco_outlined),
              const SizedBox(width: CosechaSpace.inner),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: textTheme.titleMedium
                          ?.copyWith(color: context.cosechaContent),
                    ),
                    Text(
                      product.description,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: context.cosechaContentSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: CosechaSpace.inner),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatSoles(product.price)} / ${product.unit}',
                      style: data.dataMono.copyWith(
                        color: context.cosechaContent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      l10n.productStock(product.stock, product.unit),
                      style: data.dataMonoSmall
                          .copyWith(color: context.cosechaContentSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CosechaSpace.xs),
              _QuantityStepper(
                quantity: quantity,
                unit: product.unit,
                canAdd: quantity < product.stock,
                addTooltip: l10n.productAddTooltip(product.name),
                removeTooltip: l10n.productRemoveTooltip(product.name),
                onAdd: onAdd,
                onRemove: onRemove,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// − quantity + with 48 touch targets (mint tonal buttons).
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.unit,
    required this.canAdd,
    required this.addTooltip,
    required this.removeTooltip,
    required this.onAdd,
    required this.onRemove,
  });

  final int quantity;
  final String unit;
  final bool canAdd;
  final String addTooltip;
  final String removeTooltip;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          tooltip: removeTooltip,
          onPressed: quantity > 0 ? onRemove : null,
          icon: const Icon(Icons.remove),
        ),
        Semantics(
          liveRegion: true,
          label: l10n.productInCart(quantity, unit),
          excludeSemantics: true,
          child: SizedBox(
            width: 40,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: CosechaDataText.of(context)
                  .dataMono
                  .copyWith(color: context.cosechaContent),
            ),
          ),
        ),
        IconButton.filledTonal(
          tooltip: addTooltip,
          onPressed: canAdd ? onAdd : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Sticky summary of the current order with the screen's primary action.
class _CartPanel extends StatelessWidget {
  const _CartPanel({required this.summary, required this.onReview});

  final String summary;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: scheme.outlineVariant)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: CosechaSpace.screenMargin,
            vertical: CosechaSpace.inner,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CosechaOverline(l10n.cartOverline),
                    Text(
                      summary,
                      style: CosechaDataText.of(context)
                          .dataMono
                          .copyWith(color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CosechaSpace.sm),
              CosechaPrimaryButton(
                label: l10n.reviewOrder,
                onPressed: onReview,
                expand: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _OrderReviewResult = ({String address, DateTime deliveryDate});

/// Bottom sheet to confirm the order: address and delivery date, validated
/// when tapping Save (Cosecha rule 11).
class _OrderReviewSheet extends StatefulWidget {
  const _OrderReviewSheet({required this.quantity, required this.total});

  final int quantity;
  final double total;

  @override
  State<_OrderReviewSheet> createState() => _OrderReviewSheetState();
}

class _OrderReviewSheetState extends State<_OrderReviewSheet> {
  final _formKey = GlobalKey<FormState>();
  final _address = TextEditingController();
  DateTime? _deliveryDate;

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop<_OrderReviewResult>((
      address: _address.text.trim(),
      deliveryDate: _deliveryDate!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          CosechaSpace.md,
          0,
          CosechaSpace.md,
          CosechaSpace.lg,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(l10n.orderReviewTitle, style: textTheme.titleLarge),
              ),
              const SizedBox(height: CosechaSpace.sm),
              CosechaCard(
                tone: CosechaCardTone.light,
                padding: const EdgeInsets.all(CosechaSpace.inner),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.orderReviewTotal,
                        style: textTheme.titleSmall,
                      ),
                    ),
                    Text(
                      l10n.cartSummary(
                        widget.quantity,
                        formatSoles(widget.total),
                      ),
                      style: CosechaDataText.of(context)
                          .dataMono
                          .copyWith(color: scheme.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CosechaSpace.md),
              CosechaTextField(
                label: l10n.deliveryAddressLabel,
                hint: l10n.deliveryAddressHint,
                controller: _address,
                keyboardType: TextInputType.streetAddress,
                textInputAction: TextInputAction.done,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? l10n.deliveryAddressRequired
                    : null,
              ),
              const SizedBox(height: CosechaSpace.sm),
              CosechaDateField(
                label: l10n.deliveryDateLabel,
                hint: l10n.deliveryDateHint,
                firstDate: today,
                lastDate: today.add(const Duration(days: 365)),
                onChanged: (date) => _deliveryDate = date,
                validator: (date) =>
                    date == null ? l10n.deliveryDateRequired : null,
              ),
              const SizedBox(height: CosechaSpace.md),
              CosechaPrimaryButton(label: l10n.saveOrder, onPressed: _save),
              const SizedBox(height: CosechaSpace.xs),
              Center(
                child: CosechaTextButton(
                  label: l10n.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
