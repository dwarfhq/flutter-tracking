import 'package:flutter/material.dart';
import 'package:tracking/domain/route_utils.dart';
import 'package:tracking/tracking.dart';

class PageTimeObserver extends RouteObserver<Route<dynamic>> {

  PageTimeObserver(this._tracker);

  final Tracker _tracker;

  @override
  void didPush(Route route, Route? previousRoute) {
    final routeMatchedLocation = route.navigator!.context.currentLocation;
    _tracker.trackScreen(routeMatchedLocation);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    final routeMatchedLocation = route.navigator!.context.currentLocation;
    _tracker.trackScreen(routeMatchedLocation);
    super.didPop(route, previousRoute);
  }
}
