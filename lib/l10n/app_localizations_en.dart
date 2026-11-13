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

  @override
  String get closeMenu => 'Close menu';

  @override
  String get languageTooltip => 'Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get catalogTitle => 'Commercial catalog';

  @override
  String get catalogSubtitle => 'Products and prices are demo data';

  @override
  String get catalogFilterAll => 'All';

  @override
  String get catalogFilterFruits => 'Fruits';

  @override
  String get catalogFilterVegetables => 'Vegetables';

  @override
  String get catalogEmptyTitle => 'No products in this category';

  @override
  String get catalogEmptyMessage => 'Try another filter.';

  @override
  String productStock(int quantity, String unit) {
    return 'Stock: $quantity $unit';
  }

  @override
  String productAddTooltip(String product) {
    return 'Add $product';
  }

  @override
  String productRemoveTooltip(String product) {
    return 'Remove $product';
  }

  @override
  String productInCart(int quantity, String unit) {
    return '$quantity $unit in your order';
  }

  @override
  String get cartOverline => 'Your order';

  @override
  String cartSummary(int quantity, String total) {
    return '$quantity kg · $total';
  }

  @override
  String get reviewOrder => 'Review order';

  @override
  String get orderReviewTitle => 'Confirm order';

  @override
  String get orderReviewTotal => 'Total';

  @override
  String get deliveryAddressLabel => 'Delivery address';

  @override
  String get deliveryAddressHint => 'Street, number and district';

  @override
  String get deliveryAddressRequired => 'Enter the delivery address';

  @override
  String get deliveryDateLabel => 'Delivery date';

  @override
  String get deliveryDateHint => 'Choose a date';

  @override
  String get deliveryDateRequired => 'Choose the delivery date';

  @override
  String get saveOrder => 'Save order';

  @override
  String orderReference(String order) {
    return 'Order $order';
  }

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusRejected => 'Rejected';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersSubtitle => 'Orders placed in this session (demo)';

  @override
  String get ordersEmptyTitle => 'No orders yet';

  @override
  String get ordersEmptyMessage =>
      'Add products in the catalog to create your first order.';

  @override
  String orderDeliveryDate(String date) {
    return 'Delivery: $date';
  }

  @override
  String get trackingTitle => 'Delivery tracking';

  @override
  String get trackingSubtitle => 'Live temperature and stages of your orders';

  @override
  String get trackingEmptyTitle => 'No active shipments';

  @override
  String get trackingEmptyMessage =>
      'When an order is dispatched, you will see it here.';

  @override
  String get trackingActiveShipment => 'Active shipment';

  @override
  String trackingProgress(int percent) {
    return 'Shipment progress: $percent%';
  }

  @override
  String get trackingEta => 'Estimated arrival';

  @override
  String get trackingStatusReceived => 'Received';

  @override
  String get trackingColdChain => 'Cold chain';

  @override
  String get trackingTemperature => 'Temperature';

  @override
  String get trackingHumidity => 'Humidity';

  @override
  String get trackingReefer => 'Reefer unit';

  @override
  String get trackingTransport => 'Transport';

  @override
  String get trackingEvents => 'Route checkpoints';

  @override
  String get trackingEventDone => 'Completed';

  @override
  String get trackingEventPending => 'Pending';

  @override
  String get trackingConfirmReception => 'Confirm reception';

  @override
  String get trackingReceptionDone => 'Reception confirmed';

  @override
  String get trackingReceptionDoneMessage =>
      'You already confirmed this delivery.';

  @override
  String get receptionArrived => 'Arrived at the dock';

  @override
  String get receptionProducts => 'Received products';

  @override
  String get receptionOrderRef => 'Order reference';

  @override
  String get receptionInspection => 'Inspection';

  @override
  String get receptionCompliant => 'Seal and temperature compliant';

  @override
  String receptionArrivalTemp(String temperature) {
    return 'Arrival temperature: $temperature';
  }

  @override
  String get receptionReportIncident => 'Report an incident';

  @override
  String get receptionReportIncidentDetail => 'Damaged fruit or delayed cargo';

  @override
  String get receptionNotes => 'Notes';

  @override
  String get receptionNotesHint => 'Write what you observed in the cargo';

  @override
  String get receptionConfirmed => 'Reception confirmed.';

  @override
  String get paymentsInvoices => 'Invoices';

  @override
  String get paymentsEmpty => 'No invoices yet';

  @override
  String get paymentStatusPaid => 'Paid';

  @override
  String get paymentStatusPending => 'Pending';

  @override
  String get paymentStatusOverdue => 'Overdue';

  @override
  String paymentDue(String date) {
    return 'Due $date';
  }

  @override
  String invoiceTitle(String invoice) {
    return 'Invoice $invoice';
  }

  @override
  String get invoiceOverline => 'Invoice';

  @override
  String get invoiceAmount => 'Amount';

  @override
  String get invoiceOrder => 'Order';

  @override
  String get invoiceDueDate => 'Due date';

  @override
  String get invoiceMethod => 'Payment method';

  @override
  String get invoiceSimulate => 'Simulate payment confirmation';

  @override
  String get invoiceSimulated => 'Payment simulation registered (demo)';

  @override
  String get profileContactSection => 'Business and contact';

  @override
  String get profileDemoNote => 'Demo data · changes last for this session';

  @override
  String get profileFullName => 'Full name';

  @override
  String get profileBusinessName => 'Business name';

  @override
  String get profileEmail => 'Email';

  @override
  String get profilePhone => 'Contact phone';

  @override
  String get profileTaxId => 'RUC';

  @override
  String get profileFullNameError => 'Enter your full name';

  @override
  String get profileBusinessNameError => 'Enter your business name';

  @override
  String get profileEmailError => 'Enter a valid email';

  @override
  String get profilePhoneError => 'Enter a valid phone number';

  @override
  String get profileTaxIdError => 'The RUC must have 11 digits';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileSaved => 'Profile updated for this session (demo)';

  @override
  String get featurePending => 'Implementation pending';
}
