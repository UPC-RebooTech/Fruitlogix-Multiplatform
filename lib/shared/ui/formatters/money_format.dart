import 'package:intl/intl.dart';

final NumberFormat _solesNumber = NumberFormat('#,##0.00', 'en_US');

/// Formats an amount in Peruvian soles: `S/ 1,450.00`.
///
/// Peru writes thousands with a comma and decimals with a dot in both
/// languages, so the format does not depend on the UI locale. Show the
/// result with a Mono style (`CosechaDataText.dataMono`) or `kpiNumber`.
String formatSoles(num amount) => 'S/ ${_solesNumber.format(amount)}';

/// Formats an amount in its own currency: soles as `S/ 1,450.00`, US dollars
/// as `US$ 29.00`, anything else as `EUR 10.00`.
String formatMoney(num amount, String currency) => switch (currency.toUpperCase()) {
      'PEN' => formatSoles(amount),
      'USD' => 'US\$ ${_solesNumber.format(amount)}',
      final code => '$code ${_solesNumber.format(amount)}',
    };
