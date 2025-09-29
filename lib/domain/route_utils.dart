import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension RouteUtils on BuildContext {
  String get currentLocation => GoRouter.of(this)
      .routerDelegate
      .currentConfiguration
      .last
      .matchedLocation;
}