import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UI language chosen inside the app, saved on the device.
///
/// While the user has not chosen one, [locale] is null and the app follows
/// the phone language (English unless the phone is in Spanish).
class LocaleController extends ChangeNotifier {
  LocaleController({Locale? initial, SharedPreferencesAsync? storage})
      : _locale = initial,
        _preferences = storage;

  static const String _key = 'ui_locale';

  final SharedPreferencesAsync? _preferences;
  Locale? _locale;

  Locale? get locale => _locale;

  /// Reads the saved choice. If storage is not available the app still
  /// starts, following the phone language.
  static Future<LocaleController> load() async {
    final preferences = SharedPreferencesAsync();
    Locale? saved;
    try {
      final code = await preferences.getString(_key);
      if (code != null && code.isNotEmpty) saved = Locale(code);
    } catch (_) {
      saved = null;
    }
    return LocaleController(initial: saved, storage: preferences);
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      await _preferences?.setString(_key, locale.languageCode);
    } catch (_) {
      // Keep the in-memory choice for this session.
    }
  }
}
