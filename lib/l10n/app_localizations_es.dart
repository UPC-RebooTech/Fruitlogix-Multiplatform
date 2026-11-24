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
  String get authLoginTitle => 'Iniciar sesión';

  @override
  String get authRegisterTitle => 'Crear tu cuenta';

  @override
  String get authWelcome => 'FruitLogix para clientes comerciales';

  @override
  String get authUsername => 'Usuario';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authRememberMe => 'Mantener mi sesión iniciada';

  @override
  String get authAcceptance =>
      'Acepto los Términos del servicio y la Política de privacidad';

  @override
  String get authMustAccept =>
      'Debes aceptar los términos y la política de privacidad para registrarte.';

  @override
  String get authSwitchToLogin => '¿Ya tienes cuenta? Inicia sesión';

  @override
  String get authSwitchToRegister => '¿No tienes cuenta? Regístrate';

  @override
  String get authUsernameRequired => 'Ingresa tu usuario';

  @override
  String get authInvalidUsername =>
      'Usa entre 4 y 20 letras minúsculas, números, puntos o guiones bajos.';

  @override
  String get authRequiredPassword => 'Ingresa tu contraseña';

  @override
  String get authInvalidPassword =>
      'Usa al menos 8 caracteres, incluyendo una letra y un número.';

  @override
  String get authPasswordMismatch => 'Las contraseñas no coinciden';

  @override
  String get authInvalidCredentials => 'Usuario o contraseña incorrectos';

  @override
  String get authUsernameUnavailable =>
      'El usuario no está disponible o es inválido';

  @override
  String get authNetworkError =>
      'No se pudo conectar con el servidor. Intenta de nuevo.';

  @override
  String get authServerError => 'Error del servidor. Intenta más tarde.';

  @override
  String get authUnexpectedResponse =>
      'Respuesta inesperada. Intenta otra vez.';

  @override
  String get authSignOut => 'Cerrar sesión';

  @override
  String get authLocalProfileNote =>
      'Los datos del negocio y de contacto se gestionan en Perfil.';

  @override
  String get profileLegalSection => 'Información legal';

  @override
  String get profileLegalTerms => 'Términos y Condiciones';

  @override
  String get profileLegalPrivacy => 'Política de Privacidad';

  @override
  String get profileLegalOpenError => 'No se pudo abrir el documento';

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
  String get orderStatusCancelled => 'Cancelado';

  @override
  String get ordersLoadError => 'No pudimos cargar tus pedidos';

  @override
  String get orderSendError =>
      'No pudimos registrar el pedido. Tu carrito sigue igual; inténtalo de nuevo.';

  @override
  String get orderPlaced => 'Pedido registrado';

  @override
  String get orderSending => 'Enviando pedido…';

  @override
  String get orderNotes => 'Notas para el distribuidor';

  @override
  String get orderNotesLabel => 'Notas para el distribuidor (opcional)';

  @override
  String get orderNotesHint =>
      'Horario de descarga, punto de maduración, empaque…';

  @override
  String get dashboardNoActiveOrders => 'No tienes pedidos activos.';

  @override
  String get ordersTitle => 'Mis pedidos';

  @override
  String get ordersSubtitle => 'Tus pedidos y su estado';

  @override
  String get ordersEmptyTitle => 'Aún no tienes pedidos';

  @override
  String get ordersEmptyMessage =>
      'Agrega productos en el catálogo para crear tu primer pedido.';

  @override
  String ordersTabActive(int count) {
    return 'Activos ($count)';
  }

  @override
  String ordersTabHistory(int count) {
    return 'Historial ($count)';
  }

  @override
  String get ordersHistoryEmptyTitle => 'Aún no hay pedidos en tu historial';

  @override
  String get ordersHistoryEmptyMessage =>
      'Aquí aparecerán los pedidos entregados, cancelados o rechazados.';

  @override
  String get ordersSearchHint => 'Buscar por código o producto';

  @override
  String get ordersSearchClear => 'Borrar búsqueda';

  @override
  String get ordersFilterStatus => 'Estado';

  @override
  String get ordersFilterAll => 'Todos';

  @override
  String get ordersFiltersToggle => 'Filtros';

  @override
  String ordersFiltersToggleActive(int count) {
    return 'Filtros ($count)';
  }

  @override
  String get ordersFilterDates => 'Fecha de entrega';

  @override
  String get ordersFilterProducer => 'Productor';

  @override
  String get ordersAnyDate => 'Cualquier fecha';

  @override
  String ordersDateRange(String from, String to) {
    return '$from – $to';
  }

  @override
  String get ordersClearDates => 'Quitar fechas';

  @override
  String ordersResultsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pedidos',
      one: '1 pedido',
      zero: 'Ningún pedido',
    );
    return '$_temp0';
  }

  @override
  String get ordersClearFilters => 'Limpiar filtros';

  @override
  String get ordersNoResultsTitle => 'No encontramos pedidos con estos filtros';

  @override
  String get ordersNoResultsMessage =>
      'Prueba con otra búsqueda o quita algunos filtros.';

  @override
  String get ordersProducer => 'Productor';

  @override
  String ordersProducerFallback(int id) {
    return 'Productor #$id';
  }

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
  String get trackingYourDeliveries => 'Tus entregas';

  @override
  String get trackingLoadError => 'No pudimos cargar tus entregas';

  @override
  String get trackingEtaUnknown => 'Por confirmar';

  @override
  String get trackingRoute => 'Ruta';

  @override
  String trackingRouteValue(String origin, String destination) {
    return '$origin a $destination';
  }

  @override
  String get trackingStatusScheduled => 'Programado';

  @override
  String get trackingStatusDispatched => 'Despachado';

  @override
  String get trackingStatusDelayed => 'Retrasado';

  @override
  String get trackingDriverSection => 'Conductor y vehículo';

  @override
  String get trackingDriverPending => 'Aún no se asigna un conductor';

  @override
  String get trackingVehicle => 'Vehículo';

  @override
  String get trackingPlate => 'Placa';

  @override
  String get trackingCallDriver => 'Llamar al conductor';

  @override
  String trackingCallDriverHint(String name) {
    return 'Abre el teléfono para llamar a $name';
  }

  @override
  String get trackingCallError => 'No pudimos abrir el teléfono';

  @override
  String get trackingNoReadings =>
      'La unidad de frío aún no envía lecturas de temperatura.';

  @override
  String trackingLastReading(String time) {
    return 'Última lectura: $time';
  }

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
  String get receptionRateSection => 'Calificación del servicio';

  @override
  String get receptionRateQuestion => '¿Cómo fue el servicio de entrega?';

  @override
  String get receptionRateOptional =>
      'Opcional. Toca otra vez una estrella para quitarla.';

  @override
  String get receptionNotRated => 'Sin calificar';

  @override
  String receptionStars(int stars, int max) {
    return '$stars de $max estrellas';
  }

  @override
  String get receptionRating1 => 'Muy malo';

  @override
  String get receptionRating2 => 'Malo';

  @override
  String get receptionRating3 => 'Regular';

  @override
  String get receptionRating4 => 'Bueno';

  @override
  String get receptionRating5 => 'Excelente';

  @override
  String get receptionComment => 'Comentario (opcional)';

  @override
  String get receptionCommentHint =>
      'Puntualidad, estado de la fruta, conductor…';

  @override
  String get receptionSending => 'Enviando recepción…';

  @override
  String get receptionSendError =>
      'No pudimos registrar la recepción. Inténtalo de nuevo.';

  @override
  String get receptionYourRatingLabel => 'Tu calificación:';

  @override
  String receptionYourRating(String stars) {
    return 'Tu calificación: $stars';
  }

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
  String get profilePhone => 'Celular de contacto';

  @override
  String get profileTaxId => 'RUC';

  @override
  String get profileFullNameError => 'Ingresa tu nombre completo';

  @override
  String get profileBusinessNameError => 'Ingresa la razón social';

  @override
  String get profileEmailError => 'Ingresa un correo válido';

  @override
  String get profilePhoneError =>
      'Ingresa un celular peruano válido de 9 dígitos';

  @override
  String get profileTaxIdError => 'El RUC debe tener 11 dígitos';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileSave => 'Guardar cambios';

  @override
  String get profileSaved => 'Perfil actualizado correctamente';

  @override
  String get profileStoredOnDevice =>
      'Los datos del perfil se guardan únicamente en este dispositivo.';

  @override
  String get profileSaveFailed =>
      'No se pudo guardar el perfil. Inténtalo nuevamente.';

  @override
  String get profileLoadFailed => 'No se pudo cargar tu perfil local.';

  @override
  String get profileRetry => 'Reintentar';

  @override
  String get featurePending => 'Implementación pendiente';

  @override
  String get balanceOverline => 'Balance financiero';

  @override
  String get balanceDebt => 'Deuda acumulada';

  @override
  String get balanceTotal => 'Saldo total';

  @override
  String get balanceOverdue => 'Vencido';

  @override
  String get balancePaid => 'Pagado';

  @override
  String get balanceLoading => 'Cargando tu balance…';

  @override
  String get balanceError => 'No pudimos cargar tu balance.';

  @override
  String get balanceUpToDate => 'Estás al día';

  @override
  String get paymentsLoadError => 'No pudimos cargar tus facturas.';

  @override
  String get paymentsSessionExpired =>
      'Tu sesión expiró. Vuelve a iniciar sesión para ver tus facturas.';

  @override
  String get paymentsRetry => 'Reintentar';

  @override
  String balancePendingInvoices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count facturas pendientes',
      one: '1 factura pendiente',
    );
    return '$_temp0';
  }

  @override
  String get paymentStatusFailed => 'Fallido';

  @override
  String get paymentStatusRefunded => 'Reembolsado';

  @override
  String get invoiceIssued => 'Emitida';

  @override
  String get invoicePaidAt => 'Pagada el';

  @override
  String get remindersTitle => 'Recordatorios de facturas';

  @override
  String get remindersEnabled => 'Avisarme antes del vencimiento';

  @override
  String remindersLeadDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days días antes',
      one: '1 día antes',
    );
    return '$_temp0';
  }

  @override
  String get remindersPermissionDenied =>
      'Las notificaciones de FruitLogix están desactivadas. Actívalas en los ajustes del teléfono para recibir recordatorios.';

  @override
  String remindersUpcoming(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count facturas vencen pronto',
      one: '1 factura vence pronto',
    );
    return '$_temp0';
  }

  @override
  String get remindersUpcomingDetail =>
      'Paga a tiempo y evita recargos o bloqueos de crédito';

  @override
  String reminderNotificationTitle(String invoice) {
    return 'La factura $invoice vence pronto';
  }

  @override
  String reminderNotificationBody(String amount, String date) {
    return '$amount · vence el $date. Paga a tiempo y evita recargos.';
  }

  @override
  String get invoiceReminder => 'Recordatorio';

  @override
  String get invoiceReminderNone => 'Sin recordatorio · factura pagada';

  @override
  String get invoiceReminderOff => 'Recordatorios desactivados';

  @override
  String get invoiceReminderOverdue => 'Vencida · paga lo antes posible';

  @override
  String get proTitle => 'Plan Pro';

  @override
  String get proBadge => 'Miembro Pro';

  @override
  String get proOverline => 'FruitLogix Pro';

  @override
  String get proHeadline => 'Hazte Miembro Pro';

  @override
  String proPrice(String price) {
    return '$price / mes';
  }

  @override
  String get proBenefitPriority => 'Atención prioritaria de tus pedidos';

  @override
  String get proBenefitReports => 'Reportes avanzados de compras y pagos';

  @override
  String get proBenefitAlerts => 'Alertas de cadena de frío en tiempo real';

  @override
  String get proUpgrade => 'Actualizar a Miembro Pro';

  @override
  String get proUpsellDetail => 'Actualiza tu plan sin salir de la app';

  @override
  String get proSecureNote =>
      'Pago seguro con Stripe. Los datos de tu tarjeta nunca pasan por FruitLogix.';

  @override
  String get proPreparing => 'Preparando el pago seguro…';

  @override
  String get proConfirming => 'Confirmando tu pago con Stripe…';

  @override
  String get proSuccess => '¡Bienvenido a Pro! Tu plan ya está activo.';

  @override
  String get proPending =>
      'Pago recibido. Aún esperamos la confirmación de Stripe.';

  @override
  String get proCheckAgain => 'Verificar de nuevo';

  @override
  String get proCanceled => 'Pago cancelado. No se realizó ningún cobro.';

  @override
  String get proFailed => 'No se pudo completar el pago.';

  @override
  String get proUnavailable =>
      'Los pagos con Stripe no están disponibles en este dispositivo.';

  @override
  String get proActive => 'Ya eres Miembro Pro';

  @override
  String proActiveSince(String date) {
    return 'Activo desde $date';
  }

  @override
  String get qmIncidentsTitle => 'Incidencias';

  @override
  String get qmKpiOpen => 'Abiertas';

  @override
  String get qmKpiInReview => 'En revisión';

  @override
  String get qmKpiClosed => 'Cerradas';

  @override
  String get qmReportIncident => 'Reportar una incidencia';

  @override
  String get qmNewIncidentTitle => 'Nueva incidencia';

  @override
  String get qmYourIncidents => 'Tus incidencias';

  @override
  String get qmFilterAll => 'Todas';

  @override
  String get qmStatusOpen => 'Abierta';

  @override
  String get qmStatusInReview => 'En revisión';

  @override
  String get qmStatusResolved => 'Resuelta';

  @override
  String get qmStatusRejected => 'Rechazada';

  @override
  String get qmEmptyTitle => 'No tienes incidencias';

  @override
  String get qmEmptyMessage =>
      'Si un pedido llega con problemas, repórtalo aquí con fotos.';

  @override
  String get qmEmptyFilter => 'No hay incidencias con este estado';

  @override
  String get qmLoadError => 'No pudimos cargar tus incidencias';

  @override
  String get qmRetry => 'Reintentar';

  @override
  String get qmSessionExpired => 'Tu sesión venció. Vuelve a iniciar sesión.';

  @override
  String qmIncidentTitle(String code) {
    return 'Incidencia $code';
  }

  @override
  String get qmOrder => 'Pedido';

  @override
  String get qmLot => 'Lote';

  @override
  String get qmReportedAt => 'Reportada';

  @override
  String get qmDescription => 'Descripción';

  @override
  String get qmPhotos => 'Fotos';

  @override
  String qmPhotoCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fotos',
      one: '1 foto',
      zero: 'Sin fotos',
    );
    return '$_temp0';
  }

  @override
  String qmPhotoLabel(int number) {
    return 'Foto $number';
  }

  @override
  String get qmPhotosLocalNote => 'Las fotos se guardan en este teléfono.';

  @override
  String get qmTargetLabel => 'Pedido';

  @override
  String get qmTargetRequired => 'Elige el pedido con el problema';

  @override
  String qmTargetValue(String order, String lot) {
    return '$order · Lote $lot';
  }

  @override
  String get qmDescriptionLabel => '¿Qué pasó?';

  @override
  String get qmDescriptionHint =>
      'Fruta dañada, producto equivocado, temperatura…';

  @override
  String get qmDescriptionHelper =>
      'Cuéntanos qué viste y cuántas cajas están afectadas.';

  @override
  String get qmDescriptionError =>
      'Describe el problema (mínimo 10 caracteres)';

  @override
  String qmPhotosLabel(int max) {
    return 'Fotos (opcional, hasta $max)';
  }

  @override
  String get qmAddPhoto => 'Agregar foto';

  @override
  String get qmTakePhoto => 'Tomar foto';

  @override
  String get qmChooseGallery => 'Elegir de la galería';

  @override
  String qmRemovePhoto(int number) {
    return 'Quitar foto $number';
  }

  @override
  String get qmPhotoError => 'No pudimos obtener la foto';

  @override
  String get qmSend => 'Enviar reporte';

  @override
  String get qmSent => 'Incidencia reportada';

  @override
  String get qmSendError => 'No pudimos enviar el reporte. Inténtalo de nuevo.';
}
