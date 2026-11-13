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
