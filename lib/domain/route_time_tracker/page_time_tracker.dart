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

      print(
          "qqq time for $routePath=${_pageTimes[routePath]!.toDouble() / (1000)}");
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    print("qqq didPush");
    _trackRouteTime(previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    print("qqq didPop");
    _trackRouteTime(route);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    print("qqq didRemove");
    _trackRouteTime(route);
    super.didRemove(route, previousRoute);
  }

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    print("qqq didChangeTop");
    _trackRouteTime(previousTopRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    print("qqq didReplace");
    _trackRouteTime(oldRoute);
  }

  int get _timeNowMs => DateTime.now().millisecondsSinceEpoch;
}
