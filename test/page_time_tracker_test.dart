import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/domain/route_time_tracker/page_time_tracker.dart';

void main() {
  group('PageTimeTracker', () {
    late PageTimeTracker tracker;

    setUp(() {
      tracker = PageTimeTracker();
    });

    group('initial state', () {
      test('first route switch returns event with path open_app', () {
        final event = tracker.switchRoute('/home', {});
        expect(event, isNotNull);
        expect(event!.path, 'open_app');
      });

      test('currentTimeOnRoute is non-negative on fresh instance', () {
        expect(tracker.currentTimeOnRoute, greaterThanOrEqualTo(0));
      });
    });

    group('switchRoute', () {
      test('returns null when switching to the same route', () {
        tracker.switchRoute('/home', {});
        expect(tracker.switchRoute('/home', {}), isNull);
      });

      test('returns null for repeated same-route calls', () {
        tracker.switchRoute('/home', {});
        tracker.switchRoute('/home', {});
        expect(tracker.switchRoute('/home', {}), isNull);
      });

      test('returns event when switching to a different route', () {
        tracker.switchRoute('/home', {});
        final event = tracker.switchRoute('/about', {});
        expect(event, isNotNull);
      });

      test('returned event path is the previous route', () {
        tracker.switchRoute('/home', {});
        final event = tracker.switchRoute('/about', {});
        expect(event!.path, '/home');
      });

      test('passes params to returned PageTrack', () {
        final event = tracker.switchRoute('/home', {'category': 'main'});
        expect(event!.params['category'], 'main');
      });

      test('tracks consecutive different routes correctly', () {
        final e1 = tracker.switchRoute('/home', {});
        final e2 = tracker.switchRoute('/profile', {});
        final e3 = tracker.switchRoute('/settings', {});

        expect(e1!.path, 'open_app');
        expect(e2!.path, '/home');
        expect(e3!.path, '/profile');
      });

      test('time in returned event is non-negative', () {
        tracker.switchRoute('/home', {});
        final event = tracker.switchRoute('/about', {});
        expect(event!.time, greaterThanOrEqualTo(0));
      });
    });

    group('currentTimeOnRoute', () {
      test('resets to near zero after a route switch', () {
        tracker.switchRoute('/home', {});
        tracker.switchRoute('/about', {});
        expect(tracker.currentTimeOnRoute, lessThan(500));
      });

      test('grows over time on the same route', () async {
        tracker.switchRoute('/home', {});
        final t1 = tracker.currentTimeOnRoute;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        final t2 = tracker.currentTimeOnRoute;
        expect(t2, greaterThanOrEqualTo(t1));
      });
    });
  });
}
