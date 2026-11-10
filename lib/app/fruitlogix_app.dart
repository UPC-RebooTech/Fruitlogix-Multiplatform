import 'package:flutter/material.dart';

import 'customer_shell.dart';
import 'fruitlogix_theme.dart';

class FruitLogixApp extends StatelessWidget {
  const FruitLogixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FruitLogix',
      debugShowCheckedModeBanner: false,
      theme: FruitLogixTheme.light,
      home: const CustomerShell(),
    );
  }
}
