import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Debug-only HTTP logger. Strips tokens, passwords, OTP, and KTP paths.
///
/// Must not be registered when [kReleaseMode] is true.
class SafeLogInterceptor extends LogInterceptor {
  SafeLogInterceptor()
      : super(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => debugPrint(redactSensitiveLog('$object')),
        ) {
    if (kReleaseMode) {
      throw StateError('SafeLogInterceptor is forbidden in release builds');
    }
  }
}

String redactSensitiveLog(String text) {
  var out = text;
  const keys = [
    'password_confirm',
    'password',
    'reset_token',
    'refresh',
    'access',
    'otp',
  ];
  for (final key in keys) {
    out = out.replaceAll(
      RegExp('$key:\\s*[^,}\\]\\s]+', caseSensitive: false),
      '$key: [REDACTED]',
    );
    out = out.replaceAll(
      RegExp('"$key"\\s*:\\s*"[^"]*"', caseSensitive: false),
      '"$key":"[REDACTED]"',
    );
  }
  out = out.replaceAll(
    RegExp(r'Bearer\s+\S+', caseSensitive: false),
    'Bearer [REDACTED]',
  );
  out = out.replaceAll(
    RegExp(r'lampiran_ktp[^,\]]*', caseSensitive: false),
    'lampiran_ktp: [REDACTED]',
  );
  return out;
}
