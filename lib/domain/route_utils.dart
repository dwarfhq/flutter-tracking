import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension RouteUtils on BuildContext {
  String get currentLocation {
    final router = Router.of(this);
    final routeMatchList =
        router.routerDelegate.currentConfiguration as RouteMatchList;
    if (routeMatchList.matches.isEmpty) {
      return 'empty';
    }
    return routeMatchList.last.matchedLocation;
  }

  String get goRouterCurrentLocation {
    try {
      return GoRouter.of(this)
          .routerDelegate
          .currentConfiguration
          .last
          .matchedLocation;
    } catch (e, st) {
      return "Missing router";
    }
  }
}
