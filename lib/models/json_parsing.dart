/// Shared JSON parsing helpers for API decimal, int, and datetime fields.
double parseDecimal(dynamic value, {double defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

int parseInt(dynamic value, {int defaultValue = 0}) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

double? parseOptionalDecimal(dynamic value) {
  if (value == null) return null;
  if (value is String && value.trim().isEmpty) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  return DateTime.parse(value as String);
}

DateTime? parseOptionalDateTime(dynamic value) {
  if (value == null) return null;
  return parseDateTime(value);
}
