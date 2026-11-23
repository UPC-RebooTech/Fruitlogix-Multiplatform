import 'package:flutter/material.dart';

import 'app/fruitlogix_app.dart';
import 'app/locale_controller.dart';
import 'contexts/iam/infrastructure/auth_session_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = await LocaleController.load();
  final authController = AuthSessionController();
  await authController.restore();
  runApp(FruitLogixApp(
    localeController: localeController,
    authController: authController,
  ));
}
