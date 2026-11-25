import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/cart_controller.dart';
import '../application/catalog_controller.dart';
import '../application/orders_controller.dart';
import '../domain/commercial_order.dart';
import '../domain/fruit_product.dart';
import 'order_status_view.dart';

/// Label of a category filter: the fruit type of the platform as it comes,
/// the demo groups translated.
String _categoryLabel(String category, AppLocalizations l10n) =>
    switch (category) {
      'Fruits' => l10n.catalogFilterFruits,
      'Vegetables' => l10n.catalogFilterVegetables,
      _ => category,
    };

class CustomerCatalogPage extends StatefulWidget {
  const CustomerCatalogPage({
    required this.catalog,
    required this.orders,
    required this.onOrderCreated,
    super.key,
  });

  /// Products: `GET /products` with a session, demo products without one.
  final CatalogController catalog;

  /// Places the order in the platform API (demo without session).
  final OrdersController orders;
  final VoidCallback onOrderCreated;

  @override
  State<CustomerCatalogPage> createState() => _CustomerCatalogPageState();
}

class _CustomerCatalogPageState extends State<CustomerCatalogPage> {
  late final CartController _cart;

  /// Selected fruit type; null shows every product.
  String? _category;

  @override
  void initState() {
    super.initState();
    _cart = CartController(widget.catalog.products);
    widget.catalog.addListener(_syncProducts);
    if (widget.catalog.status == CatalogStatus.idle) widget.catalog.load();
  }

  void _syncProducts() {
    if (!identical(_cart.products, widget.catalog.products)) {
      _cart.replaceProducts(widget.catalog.products);
    }
  }

  @override
  void dispose() {
    widget.catalog.removeListener(_syncProducts);
    _cart.dispose();
    super.dispose();
  }

  void _add(FruitProduct product) {
    final l10n = AppLocalizations.of(context);
    final message = switch (_cart.add(product)) {
      CartAddResult.added => null,
      CartAddResult.outOfStock => l10n.catalogNotEnoughStock,
      CartAddResult.otherProducer => l10n.catalogOneProducer,
    };
    if (message == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _reviewOrder() async {
    final result = await showModalBottomSheet<_OrderReviewResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) =>
          _OrderReviewSheet(quantity: _cart.itemCount, total: _cart.total),
    );
    if (!mounted || result == null) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await widget.orders.placeOrder(
        NewOrder(
          lines: _cart.lines,
          deliveryAddress: result.address,
          deliveryDate: result.deliveryDate,
          notes: result.notes,
        ),
      );
    } catch (error) {
      // The cart is kept so the client can retry.
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            orderErrorMessage(error, l10n, fallback: l10n.orderSendError),
          ),
        ),
      );
      return;
    }
    if (!mounted) return;
    messenger.showSnackBar(SnackBar(content: Text(l10n.orderPlaced)));
    _cart.clear();
    // Stock changed with the order.
    widget.catalog.load();
    widget.onOrderCreated();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([_cart, widget.orders, widget.catalog]),
      builder: (context, _) {
        final catalog = widget.catalog;
        final categories = {
          for (final product in _cart.products)
            if (product.category.isNotEmpty) product.category,
        }.toList();
        final visible = _cart.products
            .where((p) => _category == null || p.category == _category)
            .toList();
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
                      CosechaFilterChip(
                        label: l10n.catalogFilterAll,
                        selected: _category == null,
                        onSelected: (_) => setState(() => _category = null),
                      ),
                      for (final category in categories)
                        CosechaFilterChip(
                          label: _categoryLabel(category, l10n),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                    ],
                  ),
                  const SizedBox(height: CosechaSpace.sm),
                  if (catalog.status == CatalogStatus.loading &&
                      _cart.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(CosechaSpace.md),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (catalog.status == CatalogStatus.failure &&
                      _cart.products.isEmpty)
                    CosechaEmptyState(
                      isError: true,
                      title: orderErrorMessage(
                        catalog.error,
                        l10n,
                        fallback: l10n.catalogLoadError,
                      ),
                      action: CosechaTextButton(
                        label: l10n.qmRetry,
                        icon: Icons.refresh,
                        onPressed: catalog.load,
                      ),
                    )
                  else if (visible.isEmpty)
                    CosechaEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: l10n.catalogEmptyTitle,
                      message: l10n.catalogEmptyMessage,
                    ),
                  for (final product in visible) ...[
                    _ProductCard(
                      product: product,
                      quantity: _cart.quantityFor(product.id),
                      onAdd: () => _add(product),
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
                sending: widget.orders.submitting,
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
                      style: textTheme.titleMedium?.copyWith(
                        color: context.cosechaContent,
                      ),
                    ),
                    Text(
                      product.description,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.cosechaContentSecondary,
                      ),
                    ),
                    if (product.producerName case final producer?)
                      Text(
                        producer,
                        style: textTheme.bodySmall?.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
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
                      style: data.dataMonoSmall.copyWith(
                        color: context.cosechaContentSecondary,
                      ),
                    ),
                    if (product.minQuantity > 1)
                      Text(
                        l10n.productMinOrder(product.minQuantity, product.unit),
                        style: data.dataMonoSmall.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: CosechaSpace.xs),
              _QuantityStepper(
                quantity: quantity,
                unit: product.unit,
                canAdd: (quantity == 0 ? product.minQuantity : quantity + 1) <=
                    product.stock,
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
              style: CosechaDataText.of(context).dataMono
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
  const _CartPanel({
    required this.summary,
    required this.sending,
    required this.onReview,
  });

  final String summary;

  /// The order is being sent: the action is disabled and a bar shows it.
  final bool sending;
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
                    CosechaOverline(
                      sending ? l10n.orderSending : l10n.cartOverline,
                    ),
                    Text(
                      summary,
                      style: CosechaDataText.of(context).dataMono
                          .copyWith(color: scheme.onSurface),
                    ),
                    if (sending) ...[
                      const SizedBox(height: CosechaSpace.xxs),
                      CosechaProgressBar(
                        value: null,
                        semanticLabel: l10n.orderSending,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: CosechaSpace.sm),
              CosechaPrimaryButton(
                label: l10n.reviewOrder,
                onPressed: sending ? null : onReview,
                expand: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

typedef _OrderReviewResult = ({
  String address,
  DateTime deliveryDate,
  String? notes,
});

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
  final _notes = TextEditingController();
  DateTime? _deliveryDate;

  @override
  void dispose() {
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final notes = _notes.text.trim();
    Navigator.of(context).pop<_OrderReviewResult>((
      address: _address.text.trim(),
      deliveryDate: _deliveryDate!,
      notes: notes.isEmpty ? null : notes,
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
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
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
                      style: CosechaDataText.of(context).dataMono
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
              const SizedBox(height: CosechaSpace.sm),
              CosechaTextField(
                label: l10n.orderNotesLabel,
                hint: l10n.orderNotesHint,
                controller: _notes,
                maxLines: 2,
                textInputAction: TextInputAction.newline,
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
