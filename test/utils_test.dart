import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/data/utils.dart';

void main() {
  group('DateTimeExtension.toIso8601StringWithTz', () {
    test('UTC produces +00:00 suffix', () {
      final dt = DateTime.utc(2024, 1, 15, 10, 30, 0);
      expect(dt.toIso8601StringWithTz(), endsWith('+00:00'));
    });

    test('contains date and time components', () {
      final dt = DateTime.utc(2024, 1, 15, 10, 30, 45);
      final result = dt.toIso8601StringWithTz();
      expect(result, contains('2024-01-15'));
      expect(result, contains('T10:30:45'));
    });

    test('omits milliseconds', () {
      final dt = DateTime.utc(2024, 6, 1, 12, 0, 0, 999);
      expect(dt.toIso8601StringWithTz(), isNot(contains('.')));
    });

    test('matches format YYYY-MM-DDTHH:mm:ss±HH:MM', () {
      final dt = DateTime.utc(2024, 3, 5, 9, 7, 3);
      final result = dt.toIso8601StringWithTz();
      final pattern = RegExp(
        r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+\-]\d{2}:\d{2}$',
      );
      expect(pattern.hasMatch(result), isTrue, reason: 'Got: $result');
    });

    test('pads single-digit hours and minutes with leading zero', () {
      final dt = DateTime.utc(2024, 1, 1, 9, 5, 3);
      final result = dt.toIso8601StringWithTz();
      // Time portion should be 09:05:03
      expect(result, contains('T09:05:03'));
    });
  });
}
