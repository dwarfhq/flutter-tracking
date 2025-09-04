import 'package:flutter/widgets.dart';

class PageTimeTracker extends RouteObserver {
  var _timer = DateTime.now().millisecondsSinceEpoch;
  final _pageTimes = <String, int>{};

  void _addTime(String path) {
    final time = _timeNowMs - _timer;
    _timer = _timeNowMs;
    if (_pageTimes.containsKey(path)) {
      final cache = _pageTimes[path]!;
      _pageTimes[path] = cache + time;
    } else {
      _pageTimes[path] = time;
    }
  }

  void _trackRouteTime(Route? route) {
    final routeName = route?.settings.name;
    final routeArgs = route?.settings.arguments;
    if (routeName != null) {
      String routePath = routeName;
      if (routeArgs != null) {
        if (routeArgs is Map<String, String>) {
          for (final key in routeArgs.keys) {
            routePath =
                routePath.replaceAll(":$key", routeArgs[key].toString());
          }
        }
      }

      _addTime(routePath);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _trackRouteTime(previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _trackRouteTime(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _trackRouteTime(route);
    super.didRemove(route, previousRoute);
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    _trackRouteTime(previousTopRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _trackRouteTime(oldRoute);
  }

  int get _timeNowMs => DateTime.now().millisecondsSinceEpoch;
}
