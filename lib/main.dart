import 'package:flutter/material.dart';

import 'app/fruitlogix_app.dart';
import 'app/locale_controller.dart';
import 'contexts/iam/infrastructure/auth_session_controller.dart';
import 'contexts/payment_management/infrastructure/stripe_payment_sheet_gateway.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Native Payment Sheet (US30). No-op without STRIPE_PUBLISHABLE_KEY.
  await StripePaymentSheetGateway.initialize();
  final localeController = await LocaleController.load();
  final authController = AuthSessionController();
  await authController.restore();
  runApp(FruitLogixApp(
    localeController: localeController,
    authController: authController,
  ));
}
