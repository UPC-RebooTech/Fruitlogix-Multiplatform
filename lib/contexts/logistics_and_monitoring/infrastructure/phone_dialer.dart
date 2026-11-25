import 'package:url_launcher/url_launcher.dart';

/// Opens the phone app with a number (US77). The user still presses Call.
abstract interface class PhoneDialer {
  /// False when no app can place calls (e.g. a tablet or the web).
  Future<bool> dial(String phoneNumber);
}

class UrlLauncherPhoneDialer implements PhoneDialer {
  const UrlLauncherPhoneDialer();

  @override
  Future<bool> dial(String phoneNumber) async {
    // Keep only "+" and digits: "+51 987 111 222" → "tel:+51987111222".
    final number = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (number.isEmpty) return false;
    try {
      return await launchUrl(Uri(scheme: 'tel', path: number));
    } catch (_) {
      return false;
    }
  }
}
