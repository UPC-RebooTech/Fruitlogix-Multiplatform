import 'dart:async';

import 'package:flutter/foundation.dart';

import '../domain/membership.dart';
import '../domain/membership_repository.dart';

/// Result of the native Stripe Payment Sheet.
sealed class PaymentSheetResult {
  const PaymentSheetResult();
}

class PaymentSheetCompleted extends PaymentSheetResult {
  const PaymentSheetCompleted();
}

class PaymentSheetCanceled extends PaymentSheetResult {
  const PaymentSheetCanceled();
}

class PaymentSheetFailed extends PaymentSheetResult {
  const PaymentSheetFailed([this.message]);
  final String? message;
}

/// Port to the native payment UI (Stripe Payment Sheet).
abstract interface class PaymentSheetGateway {
  /// False on platforms without the native sheet or without a publishable key.
  bool get isAvailable;

  /// Opens the native modal over the current screen (no external browser).
  Future<PaymentSheetResult> present(ProCheckout checkout);
}

enum ProCheckoutStage {
  idle,

  /// Asking the backend for the PaymentIntent.
  preparing,

  /// Native Payment Sheet open.
  awaitingPayment,

  /// Paid in Stripe; waiting for the webhook to activate the plan.
  confirming,
  success,

  /// Paid, but the webhook has not confirmed yet.
  pendingConfirmation,
  canceled,
  failure,
}

/// US30 — Upgrades the user to "Miembro Pro" without leaving the app.
///
/// The app never marks the user as Pro on its own: it waits until the
/// backend confirms the plan (activated by the signed Stripe webhook, TS17).
class MembershipController extends ChangeNotifier {
  MembershipController({
    required MembershipRepository repository,
    required PaymentSheetGateway gateway,
    this.pollInterval = const Duration(seconds: 2),
    this.maxPolls = 15,
  })  : _repository = repository,
        _gateway = gateway;

  final MembershipRepository _repository;
  final PaymentSheetGateway _gateway;
  final Duration pollInterval;
  final int maxPolls;

  Membership _membership = Membership.free;
  ProCheckoutStage _stage = ProCheckoutStage.idle;
  Object? _error;
  bool _disposed = false;

  Membership get membership => _membership;
  bool get isPro => _membership.isPro;
  ProCheckoutStage get stage => _stage;
  Object? get error => _error;
  bool get paymentsAvailable => _gateway.isAvailable;

  bool get busy => switch (_stage) {
        ProCheckoutStage.preparing ||
        ProCheckoutStage.awaitingPayment ||
        ProCheckoutStage.confirming =>
          true,
        _ => false,
      };

  Future<void> refresh() async {
    try {
      _membership = await _repository.fetchCurrent();
      _notify();
    } catch (_) {
      // Keep the last known plan.
    }
  }

  Future<void> upgradeToPro({required String email, required String name}) async {
    if (busy || isPro) return;
    _error = null;
    _setStage(ProCheckoutStage.preparing);
    try {
      final checkout = await _repository.startProCheckout(email: email, name: name);
      _setStage(ProCheckoutStage.awaitingPayment);
      final result = await _gateway.present(checkout);
      switch (result) {
        case PaymentSheetCanceled():
          _setStage(ProCheckoutStage.canceled);
          return;
        case PaymentSheetFailed(:final message):
          _error = message;
          _setStage(ProCheckoutStage.failure);
          return;
        case PaymentSheetCompleted():
          _setStage(ProCheckoutStage.confirming);
          await _waitForWebhook();
      }
    } catch (error) {
      _error = error;
      _setStage(ProCheckoutStage.failure);
    }
  }

  /// Polls the backend until the webhook has activated the plan.
  Future<void> confirmAgain() async {
    if (busy) return;
    _setStage(ProCheckoutStage.confirming);
    await _waitForWebhook();
  }

  Future<void> _waitForWebhook() async {
    for (var attempt = 0; attempt < maxPolls; attempt++) {
      if (_disposed) return;
      try {
        final current = await _repository.fetchCurrent();
        if (current.isPro) {
          _membership = current;
          _setStage(ProCheckoutStage.success);
          return;
        }
      } catch (_) {
        // Try again on the next round.
      }
      await Future<void>.delayed(pollInterval);
    }
    _setStage(ProCheckoutStage.pendingConfirmation);
  }

  /// Back to idle after the UI showed a final stage.
  void acknowledge() {
    if (busy) return;
    _setStage(ProCheckoutStage.idle);
  }

  void _setStage(ProCheckoutStage stage) {
    _stage = stage;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
