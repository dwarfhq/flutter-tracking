import 'package:flutter/material.dart';
import 'package:tracking/data/local/event_storage.dart';
import 'package:tracking/data/remote/tracking_client.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';
import 'package:tracking/domain/route_utils.dart';
import 'package:uuid/uuid.dart';

import 'data/utils.dart';
import 'domain/route_time_tracker/page_time_tracker.dart';

class Tracker {
  final _eventStorage = EventStorage();
  final PageTimeTracker _pageTimeTracker;
  final TrackingClient _trackingClient;
  final int batchSize;
  final bool debug;
  var _isInitialised = false;
  Json _extraData = {};

  int get currentTimeOnRoute => _pageTimeTracker.currentTimeOnRoute;

  Tracker({
    required String serviceUrl,
    this.debug = false,
    this.batchSize = 5,
    Json extraData = const <String, dynamic>{},
    customEventsKey = "events",
  })  : _trackingClient = TrackingClient(
          serviceUrl,
          customEventsKey: customEventsKey,
        ),
        _extraData = extraData,
        _pageTimeTracker = PageTimeTracker();

  Future<void> initialize() async {
    try {
      await _eventStorage.init();
      _isInitialised = true;
      await sendAll();
    } catch (e, st) {
      _printError(e, st);
    }
  }

  Future<void> track(Json event) async {
    if (!_isInitialised) throw TrackingNotInitialisedException();
    _print("track($event)");
    try {
      await _eventStorage
          .addEvent(TrackEvent(data: event, cacheId: Uuid().v4()));
      final cachedEvents = await _eventStorage.getCachedEvents();
      if (cachedEvents.length >= batchSize) {
        await sendAll();
      }
    } catch (e, st) {
      _printError(e, st);
    }
  }

  void trackScreen(String route) {
    final event = _pageTimeTracker.switchRoute(route);
    _print("screen ${event?.path} -> $route, time=${event?.time}ms");
    if (event != null) {
      track(TrackEvent.fromScreen(event).toJson());
    }
  }

  void trackCurrentScreen(BuildContext context) {
    final matchedLocation = context.currentLocation;
    trackScreen(matchedLocation);
  }

  Future<void> sendAll() async {
    if (!_isInitialised) throw TrackingNotInitialisedException();
    try {
      final cachedEvents = await _eventStorage.getCachedEvents();
      _print("sendAll(), len=${cachedEvents.length}");
      final response = await _trackingClient.sendMultipleEvents(cachedEvents,
          extraData: _extraData);
      if (!response.statusCode.toString().startsWith("2")) {
        throw Exception("Tracking error: ${response.body}");
      }
      _print("response=${response.body}");
      await _eventStorage.removeEvents(cachedEvents);
      _print("sendAll() success");
    } catch (e, st) {
      _printError(e, st);
    }
  }

  void updateExtraData(Json newExtra) {
    _extraData = newExtra;
  }

  void addHeader(String key, String value) {
    _trackingClient.addHeader(key, value);
  }

  void _print(String message) {
    if (debug) print("Tracker -- $message");
  }

  void _printError(Object e, StackTrace st) {
    _print("ERROR! $e: $st");
  }
}
