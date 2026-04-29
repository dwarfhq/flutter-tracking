import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

void main() {
  group('TrackEvent', () {
    group('toJson', () {
      test('includes cache_id field', () {
        final event = TrackEvent(cacheId: 'abc123', data: {'event': 'click'});
        expect(event.toJson()['cache_id'], 'abc123');
      });

      test('merges data fields into output', () {
        final event = TrackEvent(
          cacheId: 'id1',
          data: {'event': 'click', 'page': 'home'},
        );
        final json = event.toJson();
        expect(json['event'], 'click');
        expect(json['page'], 'home');
      });

      test('data fields coexist with cache_id', () {
        final event = TrackEvent(cacheId: 'id1', data: {'foo': 'bar'});
        final json = event.toJson();
        expect(json.length, 2);
      });
    });

    group('fromJson', () {
      test('parses cache_id from json', () {
        final event = TrackEvent.fromJson({'cache_id': 'xyz', 'event': 'tap'});
        expect(event.cacheId, 'xyz');
      });

      test('stores full json as data', () {
        final json = {'cache_id': 'xyz', 'event': 'tap'};
        final event = TrackEvent.fromJson(json);
        expect(event.data, json);
      });

      test('defaults cacheId to empty string when missing', () {
        final event = TrackEvent.fromJson({'event': 'tap'});
        expect(event.cacheId, '');
      });
    });

    group('equality', () {
      test('equal when cacheIds match regardless of data', () {
        final e1 = TrackEvent(cacheId: 'same', data: {'x': 1});
        final e2 = TrackEvent(cacheId: 'same', data: {'x': 999});
        expect(e1, equals(e2));
      });

      test('not equal when cacheIds differ', () {
        final e1 = TrackEvent(cacheId: 'aaa', data: {'x': 1});
        final e2 = TrackEvent(cacheId: 'bbb', data: {'x': 1});
        expect(e1, isNot(equals(e2)));
      });

      test('not equal to non-TrackEvent', () {
        final event = TrackEvent(cacheId: 'abc', data: {});
        // ignore: unrelated_type_equality_checks
        expect(event == 'abc', isFalse);
      });
    });

    test('toString contains cacheId', () {
      final event = TrackEvent(cacheId: 'myid', data: {});
      expect(event.toString(), contains('myid'));
    });
  });
}
