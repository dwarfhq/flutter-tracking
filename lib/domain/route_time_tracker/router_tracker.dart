import 'package:flutter/widgets.dart';

class RouterTracker {
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

  void push() {}

  void pop() {}

  int get _timeNowMs => DateTime.now().millisecondsSinceEpoch;
}
