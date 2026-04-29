import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/domain/route_time_tracker/page_track.dart';

void main() {
  group('PageTrack', () {
    group('toJson', () {
      test('includes route and time', () {
        final track = PageTrack('/home', 1500, {});
        final json = track.toJson();
        expect(json['route'], '/home');
        expect(json['time'], 1500);
      });

      test('merges params into output', () {
        final track = PageTrack('/home', 1000, {'source': 'app', 'user': '42'});
        final json = track.toJson();
        expect(json['source'], 'app');
        expect(json['user'], '42');
      });

      test('params spread after route and time', () {
        // params keys override route/time if names collide
        final track = PageTrack('/home', 1000, {'route': '/overridden'});
        expect(track.toJson()['route'], '/overridden');
      });

      test('empty params produces exactly route and time keys', () {
        final track = PageTrack('/about', 200, {});
        expect(track.toJson().keys, containsAll(['route', 'time']));
        expect(track.toJson().length, 2);
      });
    });

    test('toString contains path and time', () {
      final track = PageTrack('/profile', 750, {});
      final str = track.toString();
      expect(str, contains('/profile'));
      expect(str, contains('750'));
    });
  });
}
