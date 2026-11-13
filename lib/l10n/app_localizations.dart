import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FruitLogix'**
  String get appTitle;

  /// Role shown under the business name in the top bar (rendered in uppercase).
  ///
  /// In en, this message translates to:
  /// **'Commercial client'**
  String get roleCommercialClient;

  /// No description provided for @openProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Open profile'**
  String get openProfileTooltip;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCatalog.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navTracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get navTracking;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @moreSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreSheetTitle;

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// No description provided for @paymentsDetail.
  ///
  /// In en, this message translates to:
  /// **'Invoices and pending balance'**
  String get paymentsDetail;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileDetail.
  ///
  /// In en, this message translates to:
  /// **'Business and contact details'**
  String get profileDetail;

  /// No description provided for @dashboardOverline.
  ///
  /// In en, this message translates to:
  /// **'Your dashboard'**
  String get dashboardOverline;

  /// No description provided for @dashboardWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Overview of your commercial activity'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardOverviewSection.
  ///
  /// In en, this message translates to:
  /// **'Commercial overview'**
  String get dashboardOverviewSection;

  /// No description provided for @kpiActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get kpiActiveOrders;

  /// No description provided for @kpiInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get kpiInTransit;

  /// No description provided for @kpiPendingBalance.
  ///
  /// In en, this message translates to:
  /// **'Pending balance'**
  String get kpiPendingBalance;

  /// No description provided for @dashboardQuickActionsSection.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get dashboardQuickActionsSection;

  /// No description provided for @actionNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get actionNewOrder;

  /// No description provided for @actionNewOrderDetail.
  ///
  /// In en, this message translates to:
  /// **'Browse available fruits'**
  String get actionNewOrderDetail;

  /// No description provided for @actionTrackDelivery.
  ///
  /// In en, this message translates to:
  /// **'Track delivery'**
  String get actionTrackDelivery;

  /// No description provided for @actionTrackDeliveryDetail.
  ///
  /// In en, this message translates to:
  /// **'View shipment status'**
  String get actionTrackDeliveryDetail;

  /// No description provided for @actionPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get actionPayments;

  /// No description provided for @actionPaymentsDetail.
  ///
  /// In en, this message translates to:
  /// **'Review pending balance'**
  String get actionPaymentsDetail;

  /// No description provided for @dashboardActiveOrdersSection.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get dashboardActiveOrdersSection;

  /// No description provided for @orderStatusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get orderStatusInTransit;

  /// No description provided for @orderStatusPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing'**
  String get orderStatusPreparing;

  /// No description provided for @orderExpectedAt.
  ///
  /// In en, this message translates to:
  /// **'{product} · Expected {time}'**
  String orderExpectedAt(String product, String time);

  /// No description provided for @orderProcessing.
  ///
  /// In en, this message translates to:
  /// **'{product} · Order processing'**
  String orderProcessing(String product);

  /// No description provided for @productHassAvocado.
  ///
  /// In en, this message translates to:
  /// **'Hass avocado'**
  String get productHassAvocado;

  /// No description provided for @productKentMango.
  ///
  /// In en, this message translates to:
  /// **'Kent mango'**
  String get productKentMango;

  /// No description provided for @closeMenu.
  ///
  /// In en, this message translates to:
  /// **'Close menu'**
  String get closeMenu;

  /// No description provided for @languageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTooltip;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @catalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Commercial catalog'**
  String get catalogTitle;

  /// No description provided for @catalogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Products and prices are demo data'**
  String get catalogSubtitle;

  /// No description provided for @catalogFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get catalogFilterAll;

  /// No description provided for @catalogFilterFruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get catalogFilterFruits;

  /// No description provided for @catalogFilterVegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get catalogFilterVegetables;

  /// No description provided for @catalogEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get catalogEmptyTitle;

  /// No description provided for @catalogEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try another filter.'**
  String get catalogEmptyMessage;

  /// No description provided for @productStock.
  ///
  /// In en, this message translates to:
  /// **'Stock: {quantity} {unit}'**
  String productStock(int quantity, String unit);

  /// No description provided for @productAddTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add {product}'**
  String productAddTooltip(String product);

  /// No description provided for @productRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove {product}'**
  String productRemoveTooltip(String product);

  /// Screen reader label of the quantity stepper.
  ///
  /// In en, this message translates to:
  /// **'{quantity} {unit} in your order'**
  String productInCart(int quantity, String unit);

  /// No description provided for @cartOverline.
  ///
  /// In en, this message translates to:
  /// **'Your order'**
  String get cartOverline;

  /// No description provided for @cartSummary.
  ///
  /// In en, this message translates to:
  /// **'{quantity} kg · {total}'**
  String cartSummary(int quantity, String total);

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review order'**
  String get reviewOrder;

  /// No description provided for @orderReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm order'**
  String get orderReviewTitle;

  /// No description provided for @orderReviewTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderReviewTotal;

  /// No description provided for @deliveryAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddressLabel;

  /// No description provided for @deliveryAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, number and district'**
  String get deliveryAddressHint;

  /// No description provided for @deliveryAddressRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the delivery address'**
  String get deliveryAddressRequired;

  /// No description provided for @deliveryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get deliveryDateLabel;

  /// No description provided for @deliveryDateHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a date'**
  String get deliveryDateHint;

  /// No description provided for @deliveryDateRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the delivery date'**
  String get deliveryDateRequired;

  /// No description provided for @saveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save order'**
  String get saveOrder;

  /// No description provided for @orderReference.
  ///
  /// In en, this message translates to:
  /// **'Order {order}'**
  String orderReference(String order);

  /// No description provided for @orderStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderStatusPending;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get orderStatusRejected;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'My orders'**
  String get ordersTitle;

  /// No description provided for @ordersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Orders placed in this session (demo)'**
  String get ordersSubtitle;

  /// No description provided for @ordersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get ordersEmptyTitle;

  /// No description provided for @ordersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add products in the catalog to create your first order.'**
  String get ordersEmptyMessage;

  /// No description provided for @orderDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery: {date}'**
  String orderDeliveryDate(String date);

  /// No description provided for @trackingTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery tracking'**
  String get trackingTitle;

  /// No description provided for @trackingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Live temperature and stages of your orders'**
  String get trackingSubtitle;

  /// No description provided for @trackingEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active shipments'**
  String get trackingEmptyTitle;

  /// No description provided for @trackingEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'When an order is dispatched, you will see it here.'**
  String get trackingEmptyMessage;

  /// No description provided for @trackingActiveShipment.
  ///
  /// In en, this message translates to:
  /// **'Active shipment'**
  String get trackingActiveShipment;

  /// No description provided for @trackingProgress.
  ///
  /// In en, this message translates to:
  /// **'Shipment progress: {percent}%'**
  String trackingProgress(int percent);

  /// No description provided for @trackingEta.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get trackingEta;

  /// No description provided for @trackingStatusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get trackingStatusReceived;

  /// No description provided for @trackingColdChain.
  ///
  /// In en, this message translates to:
  /// **'Cold chain'**
  String get trackingColdChain;

  /// No description provided for @trackingTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get trackingTemperature;

  /// No description provided for @trackingHumidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get trackingHumidity;

  /// No description provided for @trackingReefer.
  ///
  /// In en, this message translates to:
  /// **'Reefer unit'**
  String get trackingReefer;

  /// No description provided for @trackingTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get trackingTransport;

  /// No description provided for @trackingEvents.
  ///
  /// In en, this message translates to:
  /// **'Route checkpoints'**
  String get trackingEvents;

  /// No description provided for @trackingEventDone.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get trackingEventDone;

  /// No description provided for @trackingEventPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get trackingEventPending;

  /// No description provided for @trackingConfirmReception.
  ///
  /// In en, this message translates to:
  /// **'Confirm reception'**
  String get trackingConfirmReception;

  /// No description provided for @trackingReceptionDone.
  ///
  /// In en, this message translates to:
  /// **'Reception confirmed'**
  String get trackingReceptionDone;

  /// No description provided for @trackingReceptionDoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You already confirmed this delivery.'**
  String get trackingReceptionDoneMessage;

  /// No description provided for @receptionArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived at the dock'**
  String get receptionArrived;

  /// No description provided for @receptionProducts.
  ///
  /// In en, this message translates to:
  /// **'Received products'**
  String get receptionProducts;

  /// No description provided for @receptionOrderRef.
  ///
  /// In en, this message translates to:
  /// **'Order reference'**
  String get receptionOrderRef;

  /// No description provided for @receptionInspection.
  ///
  /// In en, this message translates to:
  /// **'Inspection'**
  String get receptionInspection;

  /// No description provided for @receptionCompliant.
  ///
  /// In en, this message translates to:
  /// **'Seal and temperature compliant'**
  String get receptionCompliant;

  /// No description provided for @receptionArrivalTemp.
  ///
  /// In en, this message translates to:
  /// **'Arrival temperature: {temperature}'**
  String receptionArrivalTemp(String temperature);

  /// No description provided for @receptionReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get receptionReportIncident;

  /// No description provided for @receptionReportIncidentDetail.
  ///
  /// In en, this message translates to:
  /// **'Damaged fruit or delayed cargo'**
  String get receptionReportIncidentDetail;

  /// No description provided for @receptionNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get receptionNotes;

  /// No description provided for @receptionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Write what you observed in the cargo'**
  String get receptionNotesHint;

  /// No description provided for @receptionConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Reception confirmed.'**
  String get receptionConfirmed;

  /// No description provided for @paymentsInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get paymentsInvoices;

  /// No description provided for @paymentsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet'**
  String get paymentsEmpty;

  /// No description provided for @paymentStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentStatusPaid;

  /// No description provided for @paymentStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentStatusPending;

  /// No description provided for @paymentStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get paymentStatusOverdue;

  /// No description provided for @paymentDue.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String paymentDue(String date);

  /// No description provided for @invoiceTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice {invoice}'**
  String invoiceTitle(String invoice);

  /// No description provided for @invoiceOverline.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceOverline;

  /// No description provided for @invoiceAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get invoiceAmount;

  /// No description provided for @invoiceOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get invoiceOrder;

  /// No description provided for @invoiceDueDate.
  ///
  /// In en, this message translates to:
  /// **'Due date'**
  String get invoiceDueDate;

  /// No description provided for @invoiceMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get invoiceMethod;

  /// No description provided for @invoiceSimulate.
  ///
  /// In en, this message translates to:
  /// **'Simulate payment confirmation'**
  String get invoiceSimulate;

  /// No description provided for @invoiceSimulated.
  ///
  /// In en, this message translates to:
  /// **'Payment simulation registered (demo)'**
  String get invoiceSimulated;

  /// No description provided for @profileContactSection.
  ///
  /// In en, this message translates to:
  /// **'Business and contact'**
  String get profileContactSection;

  /// No description provided for @profileDemoNote.
  ///
  /// In en, this message translates to:
  /// **'Demo data · changes last for this session'**
  String get profileDemoNote;

  /// No description provided for @profileFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get profileFullName;

  /// No description provided for @profileBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get profileBusinessName;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profilePhone.
  ///
  /// In en, this message translates to:
  /// **'Contact phone'**
  String get profilePhone;

  /// No description provided for @profileTaxId.
  ///
  /// In en, this message translates to:
  /// **'RUC'**
  String get profileTaxId;

  /// No description provided for @profileFullNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get profileFullNameError;

  /// No description provided for @profileBusinessNameError.
  ///
  /// In en, this message translates to:
  /// **'Enter your business name'**
  String get profileBusinessNameError;

  /// No description provided for @profileEmailError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get profileEmailError;

  /// No description provided for @profilePhoneError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get profilePhoneError;

  /// No description provided for @profileTaxIdError.
  ///
  /// In en, this message translates to:
  /// **'The RUC must have 11 digits'**
  String get profileTaxIdError;

  /// No description provided for @profileEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// No description provided for @profileSave.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get profileSave;

  /// No description provided for @profileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated for this session (demo)'**
  String get profileSaved;

  /// No description provided for @featurePending.
  ///
  /// In en, this message translates to:
  /// **'Implementation pending'**
  String get featurePending;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
