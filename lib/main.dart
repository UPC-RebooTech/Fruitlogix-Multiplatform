import 'package:flutter/material.dart';

import 'app/fruitlogix_app.dart';
import 'app/locale_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeController = await LocaleController.load();
  runApp(FruitLogixApp(localeController: localeController));
}
