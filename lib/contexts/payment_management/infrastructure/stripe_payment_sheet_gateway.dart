import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart'
    show
        FailureCode,
        PaymentSheetAppearance,
        PaymentSheetAppearanceColors,
        SetupPaymentSheetParameters,
        Stripe,
        StripeException;

import '../application/membership_controller.dart';
import '../../../shared/ui/theme/cosecha_palette.dart';
import '../domain/membership.dart';

/// US30 / TS17 — Native Stripe Payment Sheet (no external browser).
///
/// Only the publishable key lives in the app; pass it at build time:
/// `flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...`
class StripePaymentSheetGateway implements PaymentSheetGateway {
  const StripePaymentSheetGateway();

  static const String publishableKey =
      String.fromEnvironment('STRIPE_PUBLISHABLE_KEY');

  static const String merchantName = 'FruitLogix';

  static bool _initialized = false;

  static bool get _platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Call once from `main` before `runApp`.
  static Future<void> initialize() async {
    if (!_platformSupported || publishableKey.isEmpty) return;
    try {
      Stripe.publishableKey = publishableKey;
      Stripe.merchantIdentifier = 'merchant.pe.fruitlogix';
      await Stripe.instance.applySettings();
      _initialized = true;
    } catch (error) {
      debugPrint('Stripe could not be initialized: $error');
    }
  }

  @override
  bool get isAvailable => _initialized;

  @override
  Future<PaymentSheetResult> present(ProCheckout checkout) async {
    if (!_initialized) {
      return const PaymentSheetFailed('Stripe is not configured');
    }
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: checkout.clientSecret,
          merchantDisplayName: merchantName,
          style: ThemeMode.light,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: CosechaPalette.forest,
            ),
          ),
        ),
      );
      // Modal over the current screen; returns when the sheet closes.
      await Stripe.instance.presentPaymentSheet();
      return const PaymentSheetCompleted();
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return const PaymentSheetCanceled();
      }
      return PaymentSheetFailed(error.error.localizedMessage ?? error.error.message);
    } catch (error) {
      return PaymentSheetFailed(error.toString());
    }
  }
}

/// Used without a session or on unsupported platforms.
class UnavailablePaymentSheetGateway implements PaymentSheetGateway {
  const UnavailablePaymentSheetGateway();

  @override
  bool get isAvailable => false;

  @override
  Future<PaymentSheetResult> present(ProCheckout checkout) async =>
      const PaymentSheetFailed('Stripe is not available on this device');
}
