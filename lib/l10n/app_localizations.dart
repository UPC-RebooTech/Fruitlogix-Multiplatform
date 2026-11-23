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

  /// No description provided for @authLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authRegisterTitle;

  /// No description provided for @authWelcome.
  ///
  /// In en, this message translates to:
  /// **'FruitLogix for commercial clients'**
  String get authWelcome;

  /// No description provided for @authUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsername;

  /// No description provided for @authPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccount;

  /// No description provided for @authRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Keep me signed in'**
  String get authRememberMe;

  /// No description provided for @authAcceptance.
  ///
  /// In en, this message translates to:
  /// **'I accept the Terms of Service and Privacy Policy'**
  String get authAcceptance;

  /// No description provided for @authMustAccept.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and privacy policy to register.'**
  String get authMustAccept;

  /// No description provided for @authSwitchToLogin.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get authSwitchToLogin;

  /// No description provided for @authSwitchToRegister.
  ///
  /// In en, this message translates to:
  /// **'New here? Create an account'**
  String get authSwitchToRegister;

  /// No description provided for @authUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get authUsernameRequired;

  /// No description provided for @authInvalidUsername.
  ///
  /// In en, this message translates to:
  /// **'Use 4–20 lowercase letters, digits, dots or underscores.'**
  String get authInvalidUsername;

  /// No description provided for @authRequiredPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get authRequiredPassword;

  /// No description provided for @authInvalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters, including a letter and a number.'**
  String get authInvalidPassword;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get authPasswordMismatch;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get authInvalidCredentials;

  /// No description provided for @authUsernameUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Username unavailable or invalid'**
  String get authUsernameUnavailable;

  /// No description provided for @authNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to the server. Try again.'**
  String get authNetworkError;

  /// No description provided for @authServerError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get authServerError;

  /// No description provided for @authUnexpectedResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response. Please try again.'**
  String get authUnexpectedResponse;

  /// No description provided for @authSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get authSignOut;

  /// No description provided for @authLocalProfileNote.
  ///
  /// In en, this message translates to:
  /// **'Business and contact details are managed in Profile.'**
  String get authLocalProfileNote;

  /// No description provided for @profileLegalSection.
  ///
  /// In en, this message translates to:
  /// **'Legal information'**
  String get profileLegalSection;

  /// No description provided for @profileLegalTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms and Conditions'**
  String get profileLegalTerms;

  /// No description provided for @profileLegalPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get profileLegalPrivacy;

  /// No description provided for @profileLegalOpenError.
  ///
  /// In en, this message translates to:
  /// **'Unable to open the document'**
  String get profileLegalOpenError;

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
  /// **'Contact mobile'**
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
  /// **'Enter a valid 9-digit Peruvian mobile number'**
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
  /// **'Profile updated successfully'**
  String get profileSaved;

  /// No description provided for @profileStoredOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Profile information is stored on this device only.'**
  String get profileStoredOnDevice;

  /// No description provided for @profileSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save your profile. Please try again.'**
  String get profileSaveFailed;

  /// No description provided for @profileLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load your local profile.'**
  String get profileLoadFailed;

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get profileRetry;

  /// No description provided for @featurePending.
  ///
  /// In en, this message translates to:
  /// **'Implementation pending'**
  String get featurePending;

  /// No description provided for @balanceOverline.
  ///
  /// In en, this message translates to:
  /// **'Financial balance'**
  String get balanceOverline;

  /// No description provided for @balanceDebt.
  ///
  /// In en, this message translates to:
  /// **'Accumulated debt'**
  String get balanceDebt;

  /// No description provided for @balanceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total billed'**
  String get balanceTotal;

  /// No description provided for @balanceOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get balanceOverdue;

  /// No description provided for @balancePaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get balancePaid;

  /// No description provided for @balanceLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your balance…'**
  String get balanceLoading;

  /// No description provided for @balanceError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your balance.'**
  String get balanceError;

  /// No description provided for @balanceUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You\'re up to date'**
  String get balanceUpToDate;

  /// No description provided for @paymentsLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your invoices.'**
  String get paymentsLoadError;

  /// No description provided for @paymentsSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again to see your invoices.'**
  String get paymentsSessionExpired;

  /// No description provided for @paymentsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get paymentsRetry;

  /// No description provided for @balancePendingInvoices.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 pending invoice} other{{count} pending invoices}}'**
  String balancePendingInvoices(int count);

  /// No description provided for @paymentStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get paymentStatusFailed;

  /// No description provided for @paymentStatusRefunded.
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get paymentStatusRefunded;

  /// No description provided for @invoiceIssued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get invoiceIssued;

  /// No description provided for @invoicePaidAt.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get invoicePaidAt;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice reminders'**
  String get remindersTitle;

  /// No description provided for @remindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notify me before the due date'**
  String get remindersEnabled;

  /// No description provided for @remindersLeadDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day before} other{{days} days before}}'**
  String remindersLeadDays(int days);

  /// No description provided for @remindersPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off for FruitLogix. Turn them on in your phone settings to get reminders.'**
  String get remindersPermissionDenied;

  /// No description provided for @remindersUpcoming.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 invoice is due soon} other{{count} invoices are due soon}}'**
  String remindersUpcoming(int count);

  /// No description provided for @remindersUpcomingDetail.
  ///
  /// In en, this message translates to:
  /// **'Pay on time to avoid surcharges or credit holds'**
  String get remindersUpcomingDetail;

  /// No description provided for @reminderNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice {invoice} is due soon'**
  String reminderNotificationTitle(String invoice);

  /// No description provided for @reminderNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{amount} · due {date}. Pay on time to avoid surcharges.'**
  String reminderNotificationBody(String amount, String date);

  /// No description provided for @invoiceReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get invoiceReminder;

  /// No description provided for @invoiceReminderNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder · invoice already paid'**
  String get invoiceReminderNone;

  /// No description provided for @invoiceReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Reminders are turned off'**
  String get invoiceReminderOff;

  /// No description provided for @invoiceReminderOverdue.
  ///
  /// In en, this message translates to:
  /// **'Past due · pay as soon as possible'**
  String get invoiceReminderOverdue;

  /// No description provided for @proTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro plan'**
  String get proTitle;

  /// No description provided for @proBadge.
  ///
  /// In en, this message translates to:
  /// **'Pro member'**
  String get proBadge;

  /// No description provided for @proOverline.
  ///
  /// In en, this message translates to:
  /// **'FruitLogix Pro'**
  String get proOverline;

  /// No description provided for @proHeadline.
  ///
  /// In en, this message translates to:
  /// **'Become a Pro member'**
  String get proHeadline;

  /// No description provided for @proPrice.
  ///
  /// In en, this message translates to:
  /// **'{price} / month'**
  String proPrice(String price);

  /// No description provided for @proBenefitPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority attention for your orders'**
  String get proBenefitPriority;

  /// No description provided for @proBenefitReports.
  ///
  /// In en, this message translates to:
  /// **'Advanced purchase and payment reports'**
  String get proBenefitReports;

  /// No description provided for @proBenefitAlerts.
  ///
  /// In en, this message translates to:
  /// **'Real-time cold-chain alerts'**
  String get proBenefitAlerts;

  /// No description provided for @proUpgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get proUpgrade;

  /// No description provided for @proUpsellDetail.
  ///
  /// In en, this message translates to:
  /// **'Upgrade without leaving the app'**
  String get proUpsellDetail;

  /// No description provided for @proSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Secure payment with Stripe. Your card details never pass through FruitLogix.'**
  String get proSecureNote;

  /// No description provided for @proPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing secure payment…'**
  String get proPreparing;

  /// No description provided for @proConfirming.
  ///
  /// In en, this message translates to:
  /// **'Confirming your payment with Stripe…'**
  String get proConfirming;

  /// No description provided for @proSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Pro! Your plan is active.'**
  String get proSuccess;

  /// No description provided for @proPending.
  ///
  /// In en, this message translates to:
  /// **'Payment received. We\'re still waiting for Stripe\'s confirmation.'**
  String get proPending;

  /// No description provided for @proCheckAgain.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get proCheckAgain;

  /// No description provided for @proCanceled.
  ///
  /// In en, this message translates to:
  /// **'Payment canceled. You were not charged.'**
  String get proCanceled;

  /// No description provided for @proFailed.
  ///
  /// In en, this message translates to:
  /// **'The payment could not be completed.'**
  String get proFailed;

  /// No description provided for @proUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Payments with Stripe are not available on this device.'**
  String get proUnavailable;

  /// No description provided for @proActive.
  ///
  /// In en, this message translates to:
  /// **'You\'re a Pro member'**
  String get proActive;

  /// No description provided for @proActiveSince.
  ///
  /// In en, this message translates to:
  /// **'Active since {date}'**
  String proActiveSince(String date);

  /// No description provided for @qmIncidentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Incidents'**
  String get qmIncidentsTitle;

  /// No description provided for @qmKpiOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get qmKpiOpen;

  /// No description provided for @qmKpiInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get qmKpiInReview;

  /// No description provided for @qmKpiClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get qmKpiClosed;

  /// No description provided for @qmReportIncident.
  ///
  /// In en, this message translates to:
  /// **'Report an incident'**
  String get qmReportIncident;

  /// No description provided for @qmNewIncidentTitle.
  ///
  /// In en, this message translates to:
  /// **'New incident'**
  String get qmNewIncidentTitle;

  /// No description provided for @qmYourIncidents.
  ///
  /// In en, this message translates to:
  /// **'Your incidents'**
  String get qmYourIncidents;

  /// No description provided for @qmFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get qmFilterAll;

  /// No description provided for @qmStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get qmStatusOpen;

  /// No description provided for @qmStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'In review'**
  String get qmStatusInReview;

  /// No description provided for @qmStatusResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get qmStatusResolved;

  /// No description provided for @qmStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get qmStatusRejected;

  /// No description provided for @qmEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No incidents'**
  String get qmEmptyTitle;

  /// No description provided for @qmEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'If an order arrives with a problem, report it here with photos.'**
  String get qmEmptyMessage;

  /// No description provided for @qmEmptyFilter.
  ///
  /// In en, this message translates to:
  /// **'No incidents with this status'**
  String get qmEmptyFilter;

  /// No description provided for @qmLoadError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your incidents'**
  String get qmLoadError;

  /// No description provided for @qmRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get qmRetry;

  /// No description provided for @qmSessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session expired. Sign in again.'**
  String get qmSessionExpired;

  /// No description provided for @qmIncidentTitle.
  ///
  /// In en, this message translates to:
  /// **'Incident {code}'**
  String qmIncidentTitle(String code);

  /// No description provided for @qmOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get qmOrder;

  /// No description provided for @qmLot.
  ///
  /// In en, this message translates to:
  /// **'Lot'**
  String get qmLot;

  /// No description provided for @qmReportedAt.
  ///
  /// In en, this message translates to:
  /// **'Reported'**
  String get qmReportedAt;

  /// No description provided for @qmDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get qmDescription;

  /// No description provided for @qmPhotos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get qmPhotos;

  /// No description provided for @qmPhotoCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No photos} =1{1 photo} other{{count} photos}}'**
  String qmPhotoCount(int count);

  /// No description provided for @qmPhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Photo {number}'**
  String qmPhotoLabel(int number);

  /// No description provided for @qmPhotosLocalNote.
  ///
  /// In en, this message translates to:
  /// **'Photos are saved on this phone.'**
  String get qmPhotosLocalNote;

  /// No description provided for @qmTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get qmTargetLabel;

  /// No description provided for @qmTargetRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose the order with the problem'**
  String get qmTargetRequired;

  /// No description provided for @qmTargetValue.
  ///
  /// In en, this message translates to:
  /// **'{order} · Lot {lot}'**
  String qmTargetValue(String order, String lot);

  /// No description provided for @qmDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get qmDescriptionLabel;

  /// No description provided for @qmDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Damaged fruit, wrong product, temperature…'**
  String get qmDescriptionHint;

  /// No description provided for @qmDescriptionHelper.
  ///
  /// In en, this message translates to:
  /// **'Tell us what you saw and how many boxes are affected.'**
  String get qmDescriptionHelper;

  /// No description provided for @qmDescriptionError.
  ///
  /// In en, this message translates to:
  /// **'Describe the problem (at least 10 characters)'**
  String get qmDescriptionError;

  /// No description provided for @qmPhotosLabel.
  ///
  /// In en, this message translates to:
  /// **'Photos (optional, up to {max})'**
  String qmPhotosLabel(int max);

  /// No description provided for @qmAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get qmAddPhoto;

  /// No description provided for @qmTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get qmTakePhoto;

  /// No description provided for @qmChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get qmChooseGallery;

  /// No description provided for @qmRemovePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo {number}'**
  String qmRemovePhoto(int number);

  /// No description provided for @qmPhotoError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t get the photo'**
  String get qmPhotoError;

  /// No description provided for @qmSend.
  ///
  /// In en, this message translates to:
  /// **'Send report'**
  String get qmSend;

  /// No description provided for @qmSent.
  ///
  /// In en, this message translates to:
  /// **'Incident reported'**
  String get qmSent;

  /// No description provided for @qmSendError.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t send the report. Try again.'**
  String get qmSendError;
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
