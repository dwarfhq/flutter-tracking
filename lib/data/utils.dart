typedef Json = Map<String, dynamic>;

// https://github.com/dart-lang/sdk/issues/43391#issuecomment-1954335465
extension DateTimeExtension on DateTime {
  String toIso8601StringWithTz() {
    final timeZoneOffset = this.timeZoneOffset;
    final sign = timeZoneOffset.isNegative ? '-' : '+';
    final hours = timeZoneOffset.inHours.abs().toString().padLeft(2, '0');
    final minutes = timeZoneOffset.inMinutes
        .abs()
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final offsetString = '$sign$hours:$minutes';
    final formattedDate = toIso8601String().split('.').first;
    return '$formattedDate$offsetString';
  }
}
