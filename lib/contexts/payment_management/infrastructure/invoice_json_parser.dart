import '../domain/invoice.dart';

/// US36 · Scenario 2 — Normalizes invoices coming from the API.
///
/// The database may return statuses and amounts in different text formats
/// (`PAID`, `paid`, `Pagado`, `1`, `"1,450.00"`, `"S/ 600"` ...). Each value
/// is normalized here so the dashboard shows the exact balance instead of
/// dropping invoices or leaving metrics in zero.
abstract final class InvoiceJsonParser {
  /// Parses a list response. Entries that cannot be identified (no id, no
  /// amount or no due date) are skipped; every other entry is kept.
  static List<Invoice> parseList(Object? body) {
    if (body is! List) {
      throw const FormatException('Invoices response is not a list');
    }
    final invoices = <Invoice>[];
    for (final item in body) {
      if (item is! Map) continue;
      final invoice = tryParse(Map<String, dynamic>.from(item));
      if (invoice != null) invoices.add(invoice);
    }
    return invoices;
  }

  static Invoice? tryParse(Map<String, dynamic> json) {
    final fields = _normalizeKeys(json);
    final id = parseInt(fields['id']);
    final amount = parseAmount(
      fields['totalamount'] ?? fields['amount'] ?? fields['total'],
    );
    final dueDate = parseDate(fields['duedate'] ?? fields['due']);
    if (id == null || amount == null || dueDate == null) return null;

    final paidAt = parseDate(fields['paidat']);
    return Invoice(
      id: id,
      clientId: parseInt(fields['clientid'] ?? fields['commercialclientid']) ?? 0,
      orderId: parseInt(fields['orderid']),
      amount: amount,
      currency: _currency(fields['currency']),
      dueDate: dueDate,
      status: parseStatus(fields['status'], paidAt: paidAt),
      issuedAt: parseDate(fields['issuedat'], keepTime: true),
      paidAt: paidAt,
    );
  }

  /// Accepts `totalAmount`, `TotalAmount`, `total_amount`, `total-amount`.
  static Map<String, Object?> _normalizeKeys(Map<String, dynamic> json) => {
        for (final entry in json.entries)
          entry.key.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), ''):
              entry.value,
      };

  /// Status in any format. When the text is unknown, the payment date
  /// decides: paid if `paidAt` is present, pending otherwise.
  static InvoiceStatus parseStatus(Object? raw, {DateTime? paidAt}) {
    final fallback = paidAt != null ? InvoiceStatus.paid : InvoiceStatus.pending;
    if (raw == null) return fallback;

    // Backend enum order: PENDING, PAID, OVERDUE, FAILED, REFUNDED.
    if (raw is num) {
      return switch (raw.toInt()) {
        0 => InvoiceStatus.pending,
        1 => InvoiceStatus.paid,
        2 => InvoiceStatus.overdue,
        3 => InvoiceStatus.failed,
        4 => InvoiceStatus.refunded,
        _ => fallback,
      };
    }

    final text = _simplify(raw.toString());
    if (text.isEmpty) return fallback;
    if (RegExp(r'^\d+$').hasMatch(text)) {
      return parseStatus(int.parse(text), paidAt: paidAt);
    }
    bool has(List<String> words) => words.any(text.contains);

    if (has(['refund', 'reembols', 'devuel'])) return InvoiceStatus.refunded;
    if (has(['fail', 'fallid', 'rechaz', 'reject', 'declin', 'error'])) {
      return InvoiceStatus.failed;
    }
    if (has(['overdue', 'vencid', 'late', 'expired', 'atrasad', 'moros'])) {
      return InvoiceStatus.overdue;
    }
    // Before "paid": "unpaid" contains it.
    if (has(['unpaid', 'pend', 'porpagar', 'nopagad', 'open', 'issued', 'emitid'])) {
      return InvoiceStatus.pending;
    }
    if (has(['paid', 'pagad', 'pago', 'settled', 'success', 'succeeded', 'complet', 'liquidad'])) {
      return InvoiceStatus.paid;
    }
    return fallback;
  }

  /// Amount as number or text: `1450`, `"1450.5"`, `"1,450.00"`,
  /// `"1.450,00"`, `"S/ 600"`, or a money object `{amount: 600}`.
  static double? parseAmount(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is Map) {
      final value = raw['amount'] ?? raw['Amount'] ?? raw['value'];
      return parseAmount(value);
    }
    // Drop currency marks first: "S/. 600" must not become ".600".
    var text = raw
        .toString()
        .replaceAll(RegExp(r'S/\.?', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9,.\-]'), '');
    if (text.isEmpty) return null;

    final lastComma = text.lastIndexOf(',');
    final lastDot = text.lastIndexOf('.');
    if (lastComma >= 0 && lastDot >= 0) {
      // The right-most separator is the decimal one.
      final decimal = lastComma > lastDot ? ',' : '.';
      final thousands = decimal == ',' ? '.' : ',';
      text = text.replaceAll(thousands, '').replaceAll(decimal, '.');
    } else if (lastComma >= 0) {
      // "600,50" is decimal; "1,450" or "1,450,000" are thousands.
      final decimals = text.length - lastComma - 1;
      final single = text.indexOf(',') == lastComma;
      text = single && decimals > 0 && decimals <= 2
          ? text.replaceAll(',', '.')
          : text.replaceAll(',', '');
    } else if (lastDot >= 0 && text.indexOf('.') != lastDot) {
      // "1.450.000" (dots as thousands) or "1.450.50" (last is decimal).
      final decimals = text.length - lastDot - 1;
      final head = text.substring(0, lastDot).replaceAll('.', '');
      text = decimals == 3 ? '$head${text.substring(lastDot + 1)}' : '$head.${text.substring(lastDot + 1)}';
    }
    final value = double.tryParse(text);
    return value == null || value.isNaN || value.isInfinite ? null : value;
  }

  /// `2026-11-30`, `2026-11-30T00:00:00Z`, `30/11/2026` or epoch millis.
  /// For calendar dates ([keepTime] false) the written day is kept as is:
  /// no time zone conversion that could move it to the previous day.
  static DateTime? parseDate(Object? raw, {bool keepTime = false}) {
    if (raw == null) return null;
    DateTime? parsed;
    if (raw is int) {
      parsed = DateTime.fromMillisecondsSinceEpoch(raw, isUtc: true);
    } else {
      final text = raw.toString().trim();
      if (text.isEmpty) return null;
      parsed = DateTime.tryParse(text);
      if (parsed == null) {
        final match =
            RegExp(r'^(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})$').firstMatch(text);
        if (match != null) {
          parsed = DateTime(
            int.parse(match.group(3)!),
            int.parse(match.group(2)!),
            int.parse(match.group(1)!),
          );
        }
      }
    }
    if (parsed == null) return null;
    if (keepTime) return parsed.toLocal();
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static int? parseInt(Object? raw) => switch (raw) {
        int value => value,
        num value => value.toInt(),
        String value => int.tryParse(value.trim()),
        _ => null,
      };

  static String _currency(Object? raw) {
    final text = (raw ?? '').toString().trim().toUpperCase();
    if (text == 'S/' || text == 'S/.' || text == 'SOLES') return 'PEN';
    return RegExp(r'^[A-Z]{3}$').hasMatch(text) ? text : 'PEN';
  }

  /// Lowercase, without accents, spaces or punctuation.
  static String _simplify(String value) {
    const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u', 'ñ': 'n'};
    final lower = value.toLowerCase();
    final buffer = StringBuffer();
    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      final plain = accents[char] ?? char;
      if (RegExp(r'[a-z0-9]').hasMatch(plain)) buffer.write(plain);
    }
    return buffer.toString();
  }
}
