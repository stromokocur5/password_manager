/// Secure clipboard manager with auto-clear functionality.
library;

import 'dart:async';

import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

/// Manages clipboard operations with security features.
class ClipboardManager {
  Timer? _clearTimer;

  /// Copies sensitive data to clipboard and schedules auto-clear.
  ///
  /// [data] - The sensitive data to copy.
  /// [clearAfterSeconds] - Time until clipboard is cleared (default from AppConstants).
  Future<void> copySecure(String data, {int? clearAfterSeconds}) async {
    await Clipboard.setData(ClipboardData(text: data));

    // Cancel any existing timer
    _clearTimer?.cancel();

    // Schedule clipboard clear
    final seconds = clearAfterSeconds ?? AppConstants.clipboardClearSeconds;
    _clearTimer = Timer(Duration(seconds: seconds), () {
      clear();
    });
  }

  /// Immediately clears the clipboard.
  Future<void> clear() async {
    _clearTimer?.cancel();
    _clearTimer = null;
    await Clipboard.setData(const ClipboardData(text: ''));
  }

  /// Cancels the scheduled clear without clearing.
  void cancelScheduledClear() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }

  /// Disposes resources.
  void dispose() {
    _clearTimer?.cancel();
    _clearTimer = null;
  }
}
