// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'FruitLogix';

  @override
  String get roleCommercialClient => 'Cliente comercial';

  @override
  String get openProfileTooltip => 'Abrir perfil';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navOrders => 'Pedidos';

  @override
  String get navTracking => 'Seguimiento';

  @override
  String get navMore => 'Más';

  @override
  String get moreSheetTitle => 'Más';

  @override
  String get paymentsTitle => 'Pagos';

  @override
  String get paymentsDetail => 'Facturas y saldo pendiente';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileDetail => 'Datos del negocio y de contacto';

  @override
  String get dashboardOverline => 'Tu panel';

  @override
  String dashboardWelcome(String name) {
    return 'Hola, $name';
  }

  @override
  String get dashboardSubtitle => 'Resumen de tu actividad comercial';

  @override
  String get dashboardOverviewSection => 'Resumen comercial';

  @override
  String get kpiActiveOrders => 'Pedidos activos';

  @override
  String get kpiInTransit => 'En ruta';

  @override
  String get kpiPendingBalance => 'Saldo pendiente';

  @override
  String get dashboardQuickActionsSection => 'Acciones rápidas';

  @override
  String get actionNewOrder => 'Nuevo pedido';

  @override
  String get actionNewOrderDetail => 'Explora las frutas disponibles';

  @override
  String get actionTrackDelivery => 'Ver seguimiento';

  @override
  String get actionTrackDeliveryDetail => 'Consulta el estado del envío';

  @override
  String get actionPayments => 'Pagos';

  @override
  String get actionPaymentsDetail => 'Revisa tu saldo pendiente';

  @override
  String get dashboardActiveOrdersSection => 'Pedidos activos';

  @override
  String get orderStatusInTransit => 'En ruta';

  @override
  String get orderStatusPreparing => 'En preparación';

  @override
  String orderExpectedAt(String product, String time) {
    return '$product · Llega a las $time';
  }

  @override
  String orderProcessing(String product) {
    return '$product · Pedido en proceso';
  }

  @override
  String get productHassAvocado => 'Palta Hass';

  @override
  String get productKentMango => 'Mango Kent';
}
