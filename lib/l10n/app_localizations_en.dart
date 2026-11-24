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
  String get authLoginTitle => 'Sign in';

  @override
  String get authRegisterTitle => 'Create your account';

  @override
  String get authWelcome => 'FruitLogix for commercial clients';

  @override
  String get authUsername => 'Username';

  @override
  String get authPassword => 'Password';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authCreateAccount => 'Create account';

  @override
  String get authRememberMe => 'Keep me signed in';

  @override
  String get authAcceptance =>
      'I accept the Terms of Service and Privacy Policy';

  @override
  String get authMustAccept =>
      'You must accept the terms and privacy policy to register.';

  @override
  String get authSwitchToLogin => 'Already have an account? Sign in';

  @override
  String get authSwitchToRegister => 'New here? Create an account';

  @override
  String get authUsernameRequired => 'Enter your username';

  @override
  String get authInvalidUsername =>
      'Use 4–20 lowercase letters, digits, dots or underscores.';

  @override
  String get authRequiredPassword => 'Enter your password';

  @override
  String get authInvalidPassword =>
      'Use at least 8 characters, including a letter and a number.';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authInvalidCredentials => 'Invalid username or password';

  @override
  String get authUsernameUnavailable => 'Username unavailable or invalid';

  @override
  String get authNetworkError => 'Could not connect to the server. Try again.';

  @override
  String get authServerError => 'Server error. Please try again later.';

  @override
  String get authUnexpectedResponse => 'Unexpected response. Please try again.';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authLocalProfileNote =>
      'Business and contact details are managed in Profile.';

  @override
  String get profileLegalSection => 'Legal information';

  @override
  String get profileLegalTerms => 'Terms and Conditions';

  @override
  String get profileLegalPrivacy => 'Privacy Policy';

  @override
  String get profileLegalOpenError => 'Unable to open the document';

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
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get ordersLoadError => 'We couldn\'t load your orders';

  @override
  String get orderSendError =>
      'We couldn\'t place the order. Your cart was kept; try again.';

  @override
  String get orderPlaced => 'Order placed';

  @override
  String get orderSending => 'Sending order…';

  @override
  String get orderNotes => 'Notes for the distributor';

  @override
  String get orderNotesLabel => 'Notes for the distributor (optional)';

  @override
  String get orderNotesHint => 'Unloading hours, ripeness, packaging…';

  @override
  String get dashboardNoActiveOrders => 'You have no active orders.';

  @override
  String get ordersTitle => 'My orders';

  @override
  String get ordersSubtitle => 'Your orders and their status';

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
  String get trackingYourDeliveries => 'Your deliveries';

  @override
  String get trackingLoadError => 'We couldn\'t load your deliveries';

  @override
  String get trackingEtaUnknown => 'To be confirmed';

  @override
  String get trackingRoute => 'Route';

  @override
  String trackingRouteValue(String origin, String destination) {
    return '$origin to $destination';
  }

  @override
  String get trackingStatusScheduled => 'Scheduled';

  @override
  String get trackingStatusDispatched => 'Dispatched';

  @override
  String get trackingStatusDelayed => 'Delayed';

  @override
  String get trackingDriverSection => 'Driver and vehicle';

  @override
  String get trackingDriverPending => 'A driver hasn\'t been assigned yet';

  @override
  String get trackingVehicle => 'Vehicle';

  @override
  String get trackingPlate => 'Plate';

  @override
  String get trackingCallDriver => 'Call driver';

  @override
  String trackingCallDriverHint(String name) {
    return 'Opens the phone app to call $name';
  }

  @override
  String get trackingCallError => 'We couldn\'t open the phone app';

  @override
  String get trackingNoReadings =>
      'The reefer hasn\'t sent temperature readings yet.';

  @override
  String trackingLastReading(String time) {
    return 'Last reading: $time';
  }

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
  String get profilePhone => 'Contact mobile';

  @override
  String get profileTaxId => 'RUC';

  @override
  String get profileFullNameError => 'Enter your full name';

  @override
  String get profileBusinessNameError => 'Enter your business name';

  @override
  String get profileEmailError => 'Enter a valid email';

  @override
  String get profilePhoneError =>
      'Enter a valid 9-digit Peruvian mobile number';

  @override
  String get profileTaxIdError => 'The RUC must have 11 digits';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileSave => 'Save changes';

  @override
  String get profileSaved => 'Profile updated successfully';

  @override
  String get profileStoredOnDevice =>
      'Profile information is stored on this device only.';

  @override
  String get profileSaveFailed =>
      'Could not save your profile. Please try again.';

  @override
  String get profileLoadFailed => 'Could not load your local profile.';

  @override
  String get profileRetry => 'Try again';

  @override
  String get featurePending => 'Implementation pending';

  @override
  String get balanceOverline => 'Financial balance';

  @override
  String get balanceDebt => 'Accumulated debt';

  @override
  String get balanceTotal => 'Total billed';

  @override
  String get balanceOverdue => 'Overdue';

  @override
  String get balancePaid => 'Paid';

  @override
  String get balanceLoading => 'Loading your balance…';

  @override
  String get balanceError => 'We couldn\'t load your balance.';

  @override
  String get balanceUpToDate => 'You\'re up to date';

  @override
  String get paymentsLoadError => 'We couldn\'t load your invoices.';

  @override
  String get paymentsSessionExpired =>
      'Your session expired. Sign in again to see your invoices.';

  @override
  String get paymentsRetry => 'Retry';

  @override
  String balancePendingInvoices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pending invoices',
      one: '1 pending invoice',
    );
    return '$_temp0';
  }

  @override
  String get paymentStatusFailed => 'Failed';

  @override
  String get paymentStatusRefunded => 'Refunded';

  @override
  String get invoiceIssued => 'Issued';

  @override
  String get invoicePaidAt => 'Paid on';

  @override
  String get remindersTitle => 'Invoice reminders';

  @override
  String get remindersEnabled => 'Notify me before the due date';

  @override
  String remindersLeadDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days before',
      one: '1 day before',
    );
    return '$_temp0';
  }

  @override
  String get remindersPermissionDenied =>
      'Notifications are off for FruitLogix. Turn them on in your phone settings to get reminders.';

  @override
  String remindersUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count invoices are due soon',
      one: '1 invoice is due soon',
    );
    return '$_temp0';
  }

  @override
  String get remindersUpcomingDetail =>
      'Pay on time to avoid surcharges or credit holds';

  @override
  String reminderNotificationTitle(String invoice) {
    return 'Invoice $invoice is due soon';
  }

  @override
  String reminderNotificationBody(String amount, String date) {
    return '$amount · due $date. Pay on time to avoid surcharges.';
  }

  @override
  String get invoiceReminder => 'Reminder';

  @override
  String get invoiceReminderNone => 'No reminder · invoice already paid';

  @override
  String get invoiceReminderOff => 'Reminders are turned off';

  @override
  String get invoiceReminderOverdue => 'Past due · pay as soon as possible';

  @override
  String get proTitle => 'Pro plan';

  @override
  String get proBadge => 'Pro member';

  @override
  String get proOverline => 'FruitLogix Pro';

  @override
  String get proHeadline => 'Become a Pro member';

  @override
  String proPrice(String price) {
    return '$price / month';
  }

  @override
  String get proBenefitPriority => 'Priority attention for your orders';

  @override
  String get proBenefitReports => 'Advanced purchase and payment reports';

  @override
  String get proBenefitAlerts => 'Real-time cold-chain alerts';

  @override
  String get proUpgrade => 'Upgrade to Pro';

  @override
  String get proUpsellDetail => 'Upgrade without leaving the app';

  @override
  String get proSecureNote =>
      'Secure payment with Stripe. Your card details never pass through FruitLogix.';

  @override
  String get proPreparing => 'Preparing secure payment…';

  @override
  String get proConfirming => 'Confirming your payment with Stripe…';

  @override
  String get proSuccess => 'Welcome to Pro! Your plan is active.';

  @override
  String get proPending =>
      'Payment received. We\'re still waiting for Stripe\'s confirmation.';

  @override
  String get proCheckAgain => 'Check again';

  @override
  String get proCanceled => 'Payment canceled. You were not charged.';

  @override
  String get proFailed => 'The payment could not be completed.';

  @override
  String get proUnavailable =>
      'Payments with Stripe are not available on this device.';

  @override
  String get proActive => 'You\'re a Pro member';

  @override
  String proActiveSince(String date) {
    return 'Active since $date';
  }

  @override
  String get qmIncidentsTitle => 'Incidents';

  @override
  String get qmKpiOpen => 'Open';

  @override
  String get qmKpiInReview => 'In review';

  @override
  String get qmKpiClosed => 'Closed';

  @override
  String get qmReportIncident => 'Report an incident';

  @override
  String get qmNewIncidentTitle => 'New incident';

  @override
  String get qmYourIncidents => 'Your incidents';

  @override
  String get qmFilterAll => 'All';

  @override
  String get qmStatusOpen => 'Open';

  @override
  String get qmStatusInReview => 'In review';

  @override
  String get qmStatusResolved => 'Resolved';

  @override
  String get qmStatusRejected => 'Rejected';

  @override
  String get qmEmptyTitle => 'No incidents';

  @override
  String get qmEmptyMessage =>
      'If an order arrives with a problem, report it here with photos.';

  @override
  String get qmEmptyFilter => 'No incidents with this status';

  @override
  String get qmLoadError => 'We couldn\'t load your incidents';

  @override
  String get qmRetry => 'Try again';

  @override
  String get qmSessionExpired => 'Your session expired. Sign in again.';

  @override
  String qmIncidentTitle(String code) {
    return 'Incident $code';
  }

  @override
  String get qmOrder => 'Order';

  @override
  String get qmLot => 'Lot';

  @override
  String get qmReportedAt => 'Reported';

  @override
  String get qmDescription => 'Description';

  @override
  String get qmPhotos => 'Photos';

  @override
  String qmPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count photos',
      one: '1 photo',
      zero: 'No photos',
    );
    return '$_temp0';
  }

  @override
  String qmPhotoLabel(int number) {
    return 'Photo $number';
  }

  @override
  String get qmPhotosLocalNote => 'Photos are saved on this phone.';

  @override
  String get qmTargetLabel => 'Order';

  @override
  String get qmTargetRequired => 'Choose the order with the problem';

  @override
  String qmTargetValue(String order, String lot) {
    return '$order · Lot $lot';
  }

  @override
  String get qmDescriptionLabel => 'What happened?';

  @override
  String get qmDescriptionHint => 'Damaged fruit, wrong product, temperature…';

  @override
  String get qmDescriptionHelper =>
      'Tell us what you saw and how many boxes are affected.';

  @override
  String get qmDescriptionError =>
      'Describe the problem (at least 10 characters)';

  @override
  String qmPhotosLabel(int max) {
    return 'Photos (optional, up to $max)';
  }

  @override
  String get qmAddPhoto => 'Add photo';

  @override
  String get qmTakePhoto => 'Take a photo';

  @override
  String get qmChooseGallery => 'Choose from gallery';

  @override
  String qmRemovePhoto(int number) {
    return 'Remove photo $number';
  }

  @override
  String get qmPhotoError => 'We couldn\'t get the photo';

  @override
  String get qmSend => 'Send report';

  @override
  String get qmSent => 'Incident reported';

  @override
  String get qmSendError => 'We couldn\'t send the report. Try again.';
}
