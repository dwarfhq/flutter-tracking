import 'package:tracking/domain/route_time_tracker/page_track.dart';

class PageTimeTracker {
  var _timer = DateTime.now().millisecondsSinceEpoch;
  String _currentPath = "open_app";

  int get currentTimeOnRoute => _timeNowMs - _timer;

  PageTrack _addTime() {
    final time = _timeNowMs - _timer;
    _timer = _timeNowMs;
    final trackEvent = PageTrack(_currentPath, time);
    return trackEvent;
  }

  PageTrack? switchRoute(String path) {
    if (path == _currentPath) return null;
    final pageTrack = _addTime();
    _currentPath = path;
    return pageTrack;
  }

  int get _timeNowMs => DateTime.now().millisecondsSinceEpoch;
}
