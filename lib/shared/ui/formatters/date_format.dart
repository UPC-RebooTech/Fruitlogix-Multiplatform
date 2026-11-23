import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Long calendar date in the UI language: `30 de noviembre de 2026` /
/// `November 30, 2026`. Date symbols are loaded by the Material
/// localizations delegate.
String formatLongDate(BuildContext context, DateTime date) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  try {
    return DateFormat.yMMMMd(locale).format(date);
  } catch (_) {
    return formatNumericDate(date);
  }
}

/// `30/11/2026`. Safe outside the widget tree (notifications).
String formatNumericDate(DateTime date) => DateFormat('dd/MM/yyyy').format(date);
