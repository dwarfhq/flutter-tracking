import 'package:tracking/data/utils.dart';
import 'package:tracking/domain/route_time_tracker/page_track.dart';

class PageTimeTracker {
  var _timer = DateTime.now().millisecondsSinceEpoch;
  String _currentPath = "open_app";

  int get currentTimeOnRoute => _timeNowMs - _timer;

  PageTrack? switchRoute(String path, Json params) {
    if (path == _currentPath) return null;
    final time = _timeNowMs - _timer;
    _timer = _timeNowMs;
    final trackEvent = PageTrack(_currentPath, time, params);
    _currentPath = path;
    return trackEvent;
  }

  int get _timeNowMs => DateTime.now().millisecondsSinceEpoch;
}
