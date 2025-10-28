import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension RouteUtils on BuildContext {
  String get currentLocation {
    try {
      if (widget is Router<dynamic>) {
        final router = widget as Router<dynamic>;
        final routeMatchList = router.routerDelegate
            .currentConfiguration as RouteMatchList;
        if (routeMatchList.matches.isEmpty) {
          return 'empty';
        }
        return routeMatchList.last.matchedLocation;
      } else if (widget is Navigator) {
        final navigator = widget as Navigator;
        final pages = navigator.pages;
        if (pages.isEmpty) {
          return 'empty';
        }
        return pages.last.name ?? 'missing name';
      }
      return "Missing router";
    } catch (e) {
      return 'e=$e';
    }
  }
}
