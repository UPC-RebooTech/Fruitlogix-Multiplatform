// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FruitLogix';

  @override
  String get roleCommercialClient => 'Commercial client';

  @override
  String get openProfileTooltip => 'Open profile';

  @override
  String get navHome => 'Home';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navOrders => 'Orders';

  @override
  String get navTracking => 'Tracking';

  @override
  String get navMore => 'More';

  @override
  String get moreSheetTitle => 'More';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get paymentsDetail => 'Invoices and pending balance';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileDetail => 'Business and contact details';

  @override
  String get dashboardOverline => 'Your dashboard';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String get dashboardSubtitle => 'Overview of your commercial activity';

  @override
  String get dashboardOverviewSection => 'Commercial overview';

  @override
  String get kpiActiveOrders => 'Active orders';

  @override
  String get kpiInTransit => 'In transit';

  @override
  String get kpiPendingBalance => 'Pending balance';

  @override
  String get dashboardQuickActionsSection => 'Quick actions';

  @override
  String get actionNewOrder => 'New order';

  @override
  String get actionNewOrderDetail => 'Browse available fruits';

  @override
  String get actionTrackDelivery => 'Track delivery';

  @override
  String get actionTrackDeliveryDetail => 'View shipment status';

  @override
  String get actionPayments => 'Payments';

  @override
  String get actionPaymentsDetail => 'Review pending balance';

  @override
  String get dashboardActiveOrdersSection => 'Active orders';

  @override
  String get orderStatusInTransit => 'In transit';

  @override
  String get orderStatusPreparing => 'Preparing';

  @override
  String orderExpectedAt(String product, String time) {
    return '$product · Expected $time';
  }

  @override
  String orderProcessing(String product) {
    return '$product · Order processing';
  }

  @override
  String get productHassAvocado => 'Hass avocado';

  @override
  String get productKentMango => 'Kent mango';
}
