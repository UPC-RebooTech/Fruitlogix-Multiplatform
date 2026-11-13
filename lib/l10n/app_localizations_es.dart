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

  @override
  String get closeMenu => 'Cerrar menú';

  @override
  String get languageTooltip => 'Idioma';

  @override
  String get cancel => 'Cancelar';

  @override
  String get catalogTitle => 'Catálogo comercial';

  @override
  String get catalogSubtitle => 'Productos y precios de demostración';

  @override
  String get catalogFilterAll => 'Todos';

  @override
  String get catalogFilterFruits => 'Frutas';

  @override
  String get catalogFilterVegetables => 'Verduras';

  @override
  String get catalogEmptyTitle => 'No hay productos en esta categoría';

  @override
  String get catalogEmptyMessage => 'Prueba con otro filtro.';

  @override
  String productStock(int quantity, String unit) {
    return 'Disponible: $quantity $unit';
  }

  @override
  String productAddTooltip(String product) {
    return 'Agregar $product';
  }

  @override
  String productRemoveTooltip(String product) {
    return 'Quitar $product';
  }

  @override
  String productInCart(int quantity, String unit) {
    return '$quantity $unit en tu pedido';
  }

  @override
  String get cartOverline => 'Tu pedido';

  @override
  String cartSummary(int quantity, String total) {
    return '$quantity kg · $total';
  }

  @override
  String get reviewOrder => 'Revisar pedido';

  @override
  String get orderReviewTitle => 'Confirmar pedido';

  @override
  String get orderReviewTotal => 'Total';

  @override
  String get deliveryAddressLabel => 'Dirección de entrega';

  @override
  String get deliveryAddressHint => 'Calle, número y distrito';

  @override
  String get deliveryAddressRequired => 'Ingresa la dirección de entrega';

  @override
  String get deliveryDateLabel => 'Fecha de entrega';

  @override
  String get deliveryDateHint => 'Elige una fecha';

  @override
  String get deliveryDateRequired => 'Elige la fecha de entrega';

  @override
  String get saveOrder => 'Guardar pedido';

  @override
  String orderReference(String order) {
    return 'Pedido $order';
  }

  @override
  String get orderStatusPending => 'Pendiente';

  @override
  String get orderStatusDelivered => 'Entregado';

  @override
  String get orderStatusRejected => 'Rechazado';

  @override
  String get ordersTitle => 'Mis pedidos';

  @override
  String get ordersSubtitle => 'Pedidos creados en esta sesión (demo)';

  @override
  String get ordersEmptyTitle => 'Aún no tienes pedidos';

  @override
  String get ordersEmptyMessage =>
      'Agrega productos en el catálogo para crear tu primer pedido.';

  @override
  String orderDeliveryDate(String date) {
    return 'Entrega: $date';
  }

  @override
  String get trackingTitle => 'Seguimiento de entregas';

  @override
  String get trackingSubtitle => 'Temperatura en vivo y etapas de tus pedidos';

  @override
  String get trackingEmptyTitle => 'No hay envíos activos';

  @override
  String get trackingEmptyMessage =>
      'Cuando se despache un pedido, lo verás aquí.';

  @override
  String get trackingActiveShipment => 'Envío activo';

  @override
  String trackingProgress(int percent) {
    return 'Avance del envío: $percent %';
  }

  @override
  String get trackingEta => 'Llegada estimada';

  @override
  String get trackingStatusReceived => 'Recibido';

  @override
  String get trackingColdChain => 'Cadena de frío';

  @override
  String get trackingTemperature => 'Temperatura';

  @override
  String get trackingHumidity => 'Humedad';

  @override
  String get trackingReefer => 'Unidad de frío';

  @override
  String get trackingTransport => 'Transporte';

  @override
  String get trackingEvents => 'Puntos de control';

  @override
  String get trackingEventDone => 'Completado';

  @override
  String get trackingEventPending => 'Pendiente';

  @override
  String get trackingConfirmReception => 'Confirmar recepción';

  @override
  String get trackingReceptionDone => 'Recepción confirmada';

  @override
  String get trackingReceptionDoneMessage => 'Ya confirmaste esta entrega.';

  @override
  String get receptionArrived => 'Llegó al muelle';

  @override
  String get receptionProducts => 'Productos recibidos';

  @override
  String get receptionOrderRef => 'Referencia del pedido';

  @override
  String get receptionInspection => 'Inspección';

  @override
  String get receptionCompliant => 'Precinto y temperatura conformes';

  @override
  String receptionArrivalTemp(String temperature) {
    return 'Temperatura de llegada: $temperature';
  }

  @override
  String get receptionReportIncident => 'Reportar una incidencia';

  @override
  String get receptionReportIncidentDetail => 'Fruta dañada o carga retrasada';

  @override
  String get receptionNotes => 'Observaciones';

  @override
  String get receptionNotesHint => 'Escribe lo que observaste en la carga';

  @override
  String get receptionConfirmed => 'Recepción confirmada.';

  @override
  String get paymentsInvoices => 'Facturas';

  @override
  String get paymentsEmpty => 'Aún no hay facturas';

  @override
  String get paymentStatusPaid => 'Pagado';

  @override
  String get paymentStatusPending => 'Pendiente';

  @override
  String get paymentStatusOverdue => 'Vencido';

  @override
  String paymentDue(String date) {
    return 'Vence $date';
  }

  @override
  String invoiceTitle(String invoice) {
    return 'Factura $invoice';
  }

  @override
  String get invoiceOverline => 'Factura';

  @override
  String get invoiceAmount => 'Importe';

  @override
  String get invoiceOrder => 'Pedido';

  @override
  String get invoiceDueDate => 'Vencimiento';

  @override
  String get invoiceMethod => 'Método de pago';

  @override
  String get invoiceSimulate => 'Simular confirmación de pago';

  @override
  String get invoiceSimulated => 'Simulación de pago registrada (demo)';

  @override
  String get profileContactSection => 'Negocio y contacto';

  @override
  String get profileDemoNote =>
      'Datos de demostración · los cambios duran esta sesión';

  @override
  String get profileFullName => 'Nombre completo';

  @override
  String get profileBusinessName => 'Razón social';

  @override
  String get profileEmail => 'Correo electrónico';

  @override
  String get profilePhone => 'Teléfono de contacto';

  @override
  String get profileTaxId => 'RUC';

  @override
  String get profileFullNameError => 'Ingresa tu nombre completo';

  @override
  String get profileBusinessNameError => 'Ingresa la razón social';

  @override
  String get profileEmailError => 'Ingresa un correo válido';

  @override
  String get profilePhoneError => 'Ingresa un teléfono válido';

  @override
  String get profileTaxIdError => 'El RUC debe tener 11 dígitos';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String get profileSaved => 'Perfil actualizado para esta sesión (demo)';

  @override
  String get featurePending => 'Implementación pendiente';
}
