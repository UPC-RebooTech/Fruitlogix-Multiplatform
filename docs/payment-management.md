# Payment Management BC (cliente comercial)

Historias cubiertas: **US36**, **US70**, **US30** y **TS17**.

## Qué hace cada historia

| Historia | Dónde está | Cómo se cumple |
|---|---|---|
| US36 · Escenario 1 | `presentation/financial_balance_card.dart`, `application/financial_overview_controller.dart` | El dashboard se pinta al instante con un indicador de carga; cuando responde `GET /api/v1/invoices` se reemplaza por la deuda acumulada, el saldo total y lo vencido en soles (`S/ 1,450.00`). La carga nunca bloquea la navegación. |
| US36 · Escenario 2 | `infrastructure/invoice_json_parser.dart` | Normaliza estados (`PAID`, `pagado`, `Pendiente`, `1`, …), montos (`"1,450.00"`, `"1.450,00"`, `"S/. 600"`) y fechas. Una factura pendiente ya vencida cuenta como vencida. |
| US70 · Escenario 1 | `domain/invoice_reminder_policy.dart`, `application/invoice_reminder_service.dart`, `infrastructure/local_invoice_reminder_notifier.dart` | Facturas pendientes dentro del plazo configurado (1, 3 o 7 días) reciben una notificación push con número, monto y fecha. Las que están más lejos se programan para las 9:00 (hora de Lima) del día en que se abre el plazo, aunque la app esté cerrada. |
| US70 · Escenario 2 | mismo servicio | Al sincronizar (al abrir la app, al volver a ella o al refrescar), las facturas pagadas cancelan su recordatorio mostrado o programado. |
| US30 | `presentation/pro_membership_page.dart`, `application/membership_controller.dart`, `infrastructure/stripe_payment_sheet_gateway.dart` | "Más → Plan Pro" abre el Payment Sheet nativo de Stripe sobre la pantalla (sin navegador). Al pagar, la app consulta `GET /api/v1/memberships/me` hasta que el webhook activa el plan y muestra la insignia **PRO** en la cabecera. |
| TS17 | backend: `StripeWebhookController.cs`, `Membership.cs` | `POST /api/v1/payments/webhook` valida la firma `Stripe-Signature`. Con `payment_intent.succeeded` de una suscripción activa el plan PRO del usuario; con firma inválida descarta el evento y lo registra en el log como intento no verificado. |

Sin sesión (tests de widgets) el módulo usa datos demo y no llama a la red ni a plugins.

## Configuración

### App Flutter

```bash
flutter pub get
flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_xxx
# opcional, backend local:
#   --dart-define=FRUITLOGIX_API_URL=http://10.0.2.2:5000
```

La app solo lleva la clave **publicable**. Sin ella, la pantalla Pro avisa que los pagos no están disponibles en el dispositivo.

Cambios de plataforma ya incluidos:

- Android: `MainActivity` ahora es `FlutterFragmentActivity` y el tema es AppCompat (requisitos de Stripe), `minSdk` 24, desugaring y los receivers y permisos de notificaciones.
- iOS: delegado de `UNUserNotificationCenter` en `AppDelegate`.

### Backend

1. Crea la migración de la nueva tabla `memberships` (se aplica sola al arrancar por `Database.Migrate()`):
   ```bash
   dotnet ef migrations add AddMemberships
   ```
2. Configura los secretos (en Render como variables de entorno):
   - `Stripe__SecretKey=sk_test_...`
   - `Stripe__WebhookSecret=whsec_...`
3. En el Dashboard de Stripe → Developers → Webhooks, crea el endpoint
   `https://rebootech-fruitlogix-api.onrender.com/api/v1/payments/webhook`
   con el evento `payment_intent.succeeded`.
   En local: `stripe listen --forward-to localhost:5000/api/v1/payments/webhook`.

### Endpoints nuevos o cambiados

| Método | Ruta | Auth | Nota |
|---|---|---|---|
| POST | `/api/v1/payments/subscribe` | JWT | Ahora guarda `UserId` en la metadata del PaymentIntent y devuelve `paymentIntentId`, `amount` y `currency`. |
| POST | `/api/v1/payments/webhook` | Firma de Stripe | Nuevo (TS17). |
| GET | `/api/v1/memberships/me` | JWT | Nuevo. Devuelve `{ userId, plan: "FREE" \| "PRO", activatedAt }`. |

## Probar el flujo Pro

Usa la tarjeta de prueba `4242 4242 4242 4242`, con cualquier fecha futura y cualquier CVC.
