import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/order_history_filter.dart';
import '../application/supplier_performance.dart';
import '../application/orders_controller.dart';
import '../domain/commercial_order.dart';
import 'order_status_view.dart';

/// The client's orders, read from the platform API (demo without session).
///
/// Two segments: active orders and the history of finished orders (US07)
/// with search and filters by status, delivery date and producer (US08).
class CustomerOrdersPage extends StatefulWidget {
  const CustomerOrdersPage({
    required this.orders,
    required this.onNewOrder,
    this.onReportIncident,
    super.key,
  });

  final OrdersController orders;
  final VoidCallback onNewOrder;

  /// Opens the incident report (Quality Management) for an order code.
  final ValueChanged<String>? onReportIncident;

  @override
  State<CustomerOrdersPage> createState() => _CustomerOrdersPageState();
}

class _CustomerOrdersPageState extends State<CustomerOrdersPage> {
  static const int _activeTab = 0;
  static const int _historyTab = 1;

  /// Statuses a finished order can have.
  static const List<OrderStatus> _historyStatuses = [
    OrderStatus.delivered,
    OrderStatus.cancelled,
    OrderStatus.rejected,
  ];

  int _tab = _activeTab;
  bool _showFilters = false;

  /// Status, dates and producer (the search is counted apart: it is visible).
  int get _activeFilterCount =>
      (_filter.status != null ? 1 : 0) +
      (_filter.hasDateRange ? 1 : 0) +
      (_filter.producerId != null ? 1 : 0);
  OrderHistoryFilter _filter = OrderHistoryFilter.none;
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _setFilter(OrderHistoryFilter filter) =>
      setState(() => _filter = filter);

  void _clearFilters() {
    _search.clear();
    _setFilter(OrderHistoryFilter.none);
  }

  Future<void> _pickDates(List<CommercialOrder> history) async {
    final now = DateTime.now();
    final earliest = history.isEmpty
        ? DateTime(now.year - 1)
        : history
              .map((o) => o.deliveryDate)
              .reduce((a, b) => a.isBefore(b) ? a : b);
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(earliest.year, earliest.month, earliest.day),
      lastDate: DateTime(now.year + 1, now.month, now.day),
      initialDateRange: _filter.from == null || _filter.to == null
          ? null
          : DateTimeRange(start: _filter.from!, end: _filter.to!),
    );
    if (range == null || !mounted) return;
    _setFilter(_filter.copyWith(from: () => range.start, to: () => range.end));
  }

  String _producerName(AppLocalizations l10n, int id) =>
      widget.orders.producerNames[id] ?? l10n.ordersProducerFallback(id);

  @override
  Widget build(BuildContext context) {
    final orders = widget.orders;
    return ListenableBuilder(
      listenable: orders,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final all = orders.orders;
        final loading =
            !orders.hasData && orders.status != OrdersStatus.failure;
        final active = orders.activeOrders;
        final history = orders.history;

        return RefreshIndicator(
          onRefresh: orders.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              CosechaSpace.screenMargin,
              CosechaSpace.md,
              CosechaSpace.screenMargin,
              CosechaSpace.lg,
            ),
            children: [
              CosechaPageHeader(
                title: l10n.ordersTitle,
                subtitle: l10n.ordersSubtitle,
              ),
              const SizedBox(height: CosechaSpace.md),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(CosechaSpace.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (orders.status == OrdersStatus.failure && all.isEmpty)
                CosechaEmptyState(
                  isError: true,
                  title: orderErrorMessage(
                    orders.error,
                    l10n,
                    fallback: l10n.ordersLoadError,
                  ),
                  action: CosechaTextButton(
                    label: l10n.qmRetry,
                    icon: Icons.refresh,
                    onPressed: orders.load,
                  ),
                )
              else if (all.isEmpty)
                CosechaEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.ordersEmptyTitle,
                  message: l10n.ordersEmptyMessage,
                  action: CosechaPrimaryButton(
                    label: l10n.actionNewOrder,
                    icon: Icons.add,
                    onPressed: widget.onNewOrder,
                  ),
                )
              else ...[
                // One primary action per screen.
                CosechaPrimaryButton(
                  label: l10n.actionNewOrder,
                  icon: Icons.add,
                  onPressed: widget.onNewOrder,
                ),
                const SizedBox(height: CosechaSpace.md),
                CosechaSegmentedTabs(
                  labels: [
                    l10n.ordersTabActive(active.length),
                    l10n.ordersTabHistory(history.length),
                  ],
                  selectedIndex: _tab,
                  onSelected: (index) => setState(() => _tab = index),
                ),
                const SizedBox(height: CosechaSpace.sm),
                if (_tab == _activeTab)
                  ..._activeList(l10n, active)
                else
                  ..._historyList(l10n, history),
              ],
            ],
          ),
        );
      },
    );
  }

  List<Widget> _activeList(
    AppLocalizations l10n,
    List<CommercialOrder> active,
  ) {
    if (active.isEmpty) {
      return [
        CosechaEmptyState(
          icon: Icons.inventory_2_outlined,
          title: l10n.dashboardNoActiveOrders,
        ),
      ];
    }
    return [for (final order in active) ..._card(l10n, order)];
  }

  /// US07 + US08, with the supplier compliance (US24) on top.
  List<Widget> _historyList(
    AppLocalizations l10n,
    List<CommercialOrder> history,
  ) {
    final performance = _SupplierPerformanceSection(
      report: measureSupplierPerformance(
        widget.orders.orders,
        today: DateTime.now(),
      ),
      producerName: (id) => _producerName(l10n, id),
    );
    if (history.isEmpty) {
      return [
        performance,
        const SizedBox(height: CosechaSpace.md),
        CosechaEmptyState(
          icon: Icons.history,
          title: l10n.ordersHistoryEmptyTitle,
          message: l10n.ordersHistoryEmptyMessage,
        ),
      ];
    }
    final results = _filter.apply(history);
    final producers =
        {
          for (final order in history)
            if (order.producerId != null) order.producerId!,
        }.toList()..sort(
          (a, b) => _producerName(l10n, a).compareTo(_producerName(l10n, b)),
        );
    final textTheme = Theme.of(context).textTheme;
    final dateFormat = MaterialLocalizations.of(context);

    return [
      performance,
      const SizedBox(height: CosechaSpace.md),
      // Search: order code or product.
      TextField(
        controller: _search,
        onChanged: (value) => _setFilter(_filter.copyWith(query: value)),
        textInputAction: TextInputAction.search,
        style: textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: l10n.ordersSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _search.text.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.ordersSearchClear,
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _search.clear();
                    _setFilter(_filter.copyWith(query: ''));
                  },
                ),
        ),
      ),
      const SizedBox(height: CosechaSpace.xs),
      // Filters are shown progressively (report 3.1.2.4): one tap away,
      // with the number of active ones always visible.
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: CosechaTextButton(
          label: _activeFilterCount == 0
              ? l10n.ordersFiltersToggle
              : l10n.ordersFiltersToggleActive(_activeFilterCount),
          icon: _showFilters ? Icons.expand_less : Icons.tune,
          onPressed: () => setState(() => _showFilters = !_showFilters),
        ),
      ),
      if (_showFilters) ...[
        const SizedBox(height: CosechaSpace.xs),
        CosechaOverline(l10n.ordersFilterStatus),
        const SizedBox(height: CosechaSpace.xs),
        Wrap(
          spacing: CosechaSpace.xs,
          runSpacing: CosechaSpace.xs,
          children: [
            CosechaFilterChip(
              label: l10n.ordersFilterAll,
              selected: _filter.status == null,
              onSelected: (_) =>
                  _setFilter(_filter.copyWith(status: () => null)),
            ),
            for (final status in _historyStatuses)
              CosechaFilterChip(
                label: orderStatusView(status, l10n).label,
                selected: _filter.status == status,
                onSelected: (_) =>
                    _setFilter(_filter.copyWith(status: () => status)),
              ),
          ],
        ),
        const SizedBox(height: CosechaSpace.sm),
        CosechaOverline(l10n.ordersFilterDates),
        const SizedBox(height: CosechaSpace.xs),
        Wrap(
          spacing: CosechaSpace.xs,
          runSpacing: CosechaSpace.xs,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CosechaFilterChip(
              label: _filter.hasDateRange
                  ? l10n.ordersDateRange(
                      dateFormat.formatShortDate(_filter.from!),
                      dateFormat.formatShortDate(_filter.to!),
                    )
                  : l10n.ordersAnyDate,
              selected: _filter.hasDateRange,
              onSelected: (_) => _pickDates(history),
            ),
            if (_filter.hasDateRange)
              CosechaTextButton(
                label: l10n.ordersClearDates,
                onPressed: () => _setFilter(
                  _filter.copyWith(from: () => null, to: () => null),
                ),
              ),
          ],
        ),
        if (producers.isNotEmpty) ...[
          const SizedBox(height: CosechaSpace.sm),
          CosechaOverline(l10n.ordersFilterProducer),
          const SizedBox(height: CosechaSpace.xs),
          Wrap(
            spacing: CosechaSpace.xs,
            runSpacing: CosechaSpace.xs,
            children: [
              CosechaFilterChip(
                label: l10n.ordersFilterAll,
                selected: _filter.producerId == null,
                onSelected: (_) =>
                    _setFilter(_filter.copyWith(producerId: () => null)),
              ),
              for (final id in producers)
                CosechaFilterChip(
                  label: _producerName(l10n, id),
                  selected: _filter.producerId == id,
                  onSelected: (_) =>
                      _setFilter(_filter.copyWith(producerId: () => id)),
                ),
            ],
          ),
        ],
      ],
      const SizedBox(height: CosechaSpace.sm),
      Row(
        children: [
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                l10n.ordersResultsCount(results.length),
                style: textTheme.bodySmall?.copyWith(
                  color: context.cosechaContentSecondary,
                ),
              ),
            ),
          ),
          if (_filter.isActive)
            CosechaTextButton(
              label: l10n.ordersClearFilters,
              onPressed: _clearFilters,
            ),
        ],
      ),
      const SizedBox(height: CosechaSpace.xs),
      if (results.isEmpty)
        CosechaEmptyState(
          icon: Icons.search_off,
          title: l10n.ordersNoResultsTitle,
          message: l10n.ordersNoResultsMessage,
          action: CosechaTextButton(
            label: l10n.ordersClearFilters,
            icon: Icons.filter_alt_off_outlined,
            onPressed: _clearFilters,
          ),
        )
      else
        for (final order in results) ..._card(l10n, order),
    ];
  }

  List<Widget> _card(AppLocalizations l10n, CommercialOrder order) {
    // Incidents make sense for orders that arrived or are on their way.
    final canReport =
        widget.onReportIncident != null &&
        order.status != OrderStatus.cancelled &&
        order.status != OrderStatus.rejected;
    return [
      _OrderCard(
        order: order,
        producerName: order.producerId == null
            ? null
            : _producerName(l10n, order.producerId!),
        onReportIncident: canReport
            ? () => widget.onReportIncident!(order.code)
            : null,
      ),
      const SizedBox(height: CosechaSpace.xs),
    ];
  }
}

/// US24 — Compliance per supplier: overall KPIs and one row per producer.
/// Scenario 2: a message when there is nothing to measure yet.
class _SupplierPerformanceSection extends StatelessWidget {
  const _SupplierPerformanceSection({
    required this.report,
    required this.producerName,
  });

  final SupplierPerformanceReport report;
  final String Function(int producerId) producerName;

  /// ≥ 90 % meets, ≥ 70 % fair, otherwise low.
  static ({String label, CosechaStatus status}) _level(
    SupplierPerformance supplier,
    AppLocalizations l10n,
  ) {
    final percent = supplier.onTimePercent;
    if (percent >= 90) {
      return (label: l10n.performanceGood, status: CosechaStatus.success);
    }
    if (percent >= 70) {
      return (label: l10n.performanceFair, status: CosechaStatus.warning);
    }
    return (label: l10n.performanceLow, status: CosechaStatus.critical);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);

    if (!report.hasData) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CosechaOverline(l10n.performanceTitle),
          const SizedBox(height: CosechaSpace.xs),
          CosechaCard(
            tone: CosechaCardTone.light,
            child: Row(
              children: [
                const CosechaIconBox(icon: Icons.insights_outlined),
                const SizedBox(width: CosechaSpace.inner),
                Expanded(
                  child: Text(
                    l10n.performanceNoData,
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.cosechaContentSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final overall = report.overall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CosechaOverline(l10n.performanceTitle),
        const SizedBox(height: CosechaSpace.xs),
        Row(
          children: [
            Expanded(
              child: CosechaKpiCard(
                compact: true,
                label: l10n.performanceOnTime,
                value: '${overall.onTimePercent} %',
              ),
            ),
            const SizedBox(width: CosechaSpace.xs),
            Expanded(
              child: CosechaKpiCard(
                compact: true,
                label: l10n.performanceLate,
                value: '${overall.latePercent} %',
              ),
            ),
          ],
        ),
        const SizedBox(height: CosechaSpace.xs),
        CosechaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < report.suppliers.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
                    child: Divider(),
                  ),
                Builder(
                  builder: (context) {
                    final supplier = report.suppliers[i];
                    final level = _level(supplier, l10n);
                    final name = producerName(supplier.producerId);
                    final detail = l10n.performanceDetail(
                      supplier.onTime,
                      supplier.total,
                      supplier.late,
                    );
                    return Semantics(
                      container: true,
                      label:
                          '$name, ${supplier.onTimePercent} %, '
                          '${level.label}, $detail',
                      excludeSemantics: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: textTheme.titleSmall?.copyWith(
                                    color: context.cosechaContent,
                                  ),
                                ),
                              ),
                              Text(
                                '${supplier.onTimePercent} %',
                                style: data.dataMono.copyWith(
                                  color: context.cosechaContent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: CosechaSpace.xs),
                              CosechaStatusTag(
                                label: level.label,
                                status: level.status,
                              ),
                            ],
                          ),
                          const SizedBox(height: CosechaSpace.xs),
                          CosechaProgressBar(value: supplier.onTimeRate),
                          const SizedBox(height: CosechaSpace.xxs),
                          Text(
                            detail,
                            style: textTheme.bodySmall?.copyWith(
                              color: context.cosechaContentSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: CosechaSpace.inner),
              Text(
                l10n.performanceNote,
                style: textTheme.bodySmall?.copyWith(
                  color: context.cosechaContentSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    this.producerName,
    this.onReportIncident,
  });

  final CommercialOrder order;
  final String? producerName;
  final VoidCallback? onReportIncident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = orderStatusView(order.status, l10n);
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(order.deliveryDate);

    return CosechaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: data.dataMono.copyWith(
                    color: context.cosechaContent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: CosechaSpace.xs),
              CosechaStatusTag(label: status.label, status: status.status),
            ],
          ),
          const SizedBox(height: CosechaSpace.inner),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: CosechaSpace.xxs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.product.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.cosechaContent,
                      ),
                    ),
                  ),
                  Text(
                    '${line.quantity} ${line.product.unit}',
                    style: data.dataMonoSmall.copyWith(
                      color: context.cosechaContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: CosechaSpace.xs),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.orderReviewTotal,
                  style: textTheme.titleSmall?.copyWith(
                    color: context.cosechaContent,
                  ),
                ),
              ),
              Text(
                formatSoles(order.total),
                style: data.dataMono.copyWith(
                  color: context.cosechaContent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: CosechaSpace.inner),
          CosechaInfoRow(
            icon: Icons.event_outlined,
            label: l10n.deliveryDateLabel,
            value: date,
          ),
          if (producerName != null) ...[
            const SizedBox(height: CosechaSpace.xs),
            CosechaInfoRow(
              icon: Icons.agriculture_outlined,
              label: l10n.ordersProducer,
              value: producerName!,
            ),
          ],
          const SizedBox(height: CosechaSpace.xs),
          CosechaInfoRow(
            icon: Icons.place_outlined,
            label: l10n.deliveryAddressLabel,
            value: order.deliveryAddress,
          ),
          if (order.notes != null) ...[
            const SizedBox(height: CosechaSpace.xs),
            CosechaInfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: l10n.orderNotes,
              value: order.notes!,
            ),
          ],
          if (onReportIncident != null) ...[
            const SizedBox(height: CosechaSpace.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CosechaTextButton(
                label: l10n.qmReportIncident,
                icon: Icons.report_problem_outlined,
                onPressed: onReportIncident,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
