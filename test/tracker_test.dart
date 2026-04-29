import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/tracking.dart';

void main() {
  group('Tracker', () {
    group('before initialize()', () {
      late Tracker tracker;

      setUp(() {
        tracker = Tracker(serviceUrl: 'https://example.com/events');
      });

      test('track() throws TrackingNotInitialisedException', () async {
        await expectLater(
          tracker.track({'event': 'test'}),
          throwsA(isA<TrackingNotInitialisedException>()),
        );
      });

      test('sendAll() throws TrackingNotInitialisedException', () async {
        await expectLater(
          tracker.sendAll(),
          throwsA(isA<TrackingNotInitialisedException>()),
        );
      });
    });

    group('updateExtraData', () {
      test('does not throw', () {
        final tracker = Tracker(serviceUrl: 'https://example.com');
        expect(() => tracker.updateExtraData({'version': '2.0'}), returnsNormally);
      });

      test('can be called multiple times', () {
        final tracker = Tracker(serviceUrl: 'https://example.com');
        tracker.updateExtraData({'a': 1});
        tracker.updateExtraData({'b': 2});
        // No assertion on internal state — just verifying no exception thrown
      });
    });

    group('addHeader', () {
      test('does not throw', () {
        final tracker = Tracker(serviceUrl: 'https://example.com');
        expect(
          () => tracker.addHeader('Authorization', 'Bearer token'),
          returnsNormally,
        );
      });
    });

    group('trackScreen', () {
      test('does not throw when route is unchanged (no event emitted)', () {
        final tracker = Tracker(serviceUrl: 'https://example.com');
        // Switching to 'open_app' matches the initial path, so switchRoute
        // returns null and track() is never called — safe to call uninitialized.
        expect(() => tracker.trackScreen('open_app'), returnsNormally);
      });
    });

    group('currentTimeOnRoute', () {
      test('returns non-negative value', () {
        final tracker = Tracker(serviceUrl: 'https://example.com');
        expect(tracker.currentTimeOnRoute, greaterThanOrEqualTo(0));
      });
    });
  });

  group('TrackingNotInitialisedException', () {
    test('message mentions initialize()', () {
      expect(
        TrackingNotInitialisedException().message,
        contains('initialize()'),
      );
    });
  });

  group('TrackingTimeoutException', () {
    test('message is non-empty', () {
      expect(TrackingTimeoutException().message, isNotEmpty);
    });

    test('message mentions caching or timeout', () {
      final msg = TrackingTimeoutException().message.toLowerCase();
      expect(msg, anyOf(contains('timeout'), contains('cach')));
    });
  });
}
