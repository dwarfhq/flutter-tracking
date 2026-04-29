import 'package:tracking/data/local/event_storage.dart';
import 'package:tracking/data/remote/tracking_client.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';
import 'data/utils.dart';
import 'domain/route_time_tracker/page_time_tracker.dart';
import 'package:collection/collection.dart';

class Tracker {
  final _mapEq = DeepCollectionEquality();
  final EventStorage _eventStorage;
  final PageTimeTracker _pageTimeTracker;
  final TrackingClient _trackingClient;
  final int batchSize;
  final bool debug;
  ErrorCallback? _onError;
  var _isInitialised = false;
  Json _extraData = {};

  int get currentTimeOnRoute => _pageTimeTracker.currentTimeOnRoute;

  Tracker({
    required String serviceUrl,
    this.debug = false,
    this.batchSize = 5,
    Json extraData = const <String, dynamic>{},
    String storageKey = "tracking_events",
    customEventsKey = "events",
  })  : _trackingClient = TrackingClient(
          serviceUrl,
          customEventsKey: customEventsKey,
        ),
        _eventStorage = EventStorage(storageKey),
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
    try {
      final cacheId = _mapEq.hash(event).toString();
      final trackEvent = TrackEvent(data: event, cacheId: cacheId);
      _print("track(${trackEvent.toJson()})");
      await _eventStorage.addEvent(trackEvent);
      final cachedEvents = await _eventStorage.getCachedEvents();
      if (cachedEvents.length >= batchSize) {
        await sendAll();
      }
    } catch (e, st) {
      _printError(e, st);
      _onError?.call(e, st);
    }
  }

  void trackScreen(String route, {Json params = const {}}) {
    final event = _pageTimeTracker.switchRoute(route, {
      "source": "app",
      "category": "screen",
      "event": "screen_view",
      "created_at": DateTime.now().toIso8601StringWithTz(),
    });
    _print("screen ${event?.path} -> $route, time=${event?.time}ms");
    if (event != null) {
      final cacheId = _mapEq.hash(event).toString();
      track(TrackEvent(data: event.toJson(), cacheId: cacheId).toJson());
    }
  }

  Future<void> sendAll() async {
    if (!_isInitialised) throw TrackingNotInitialisedException();
    try {
      final cachedEvents = await _eventStorage.getCachedEvents();
      _print("sendAll(), len=${cachedEvents.length}");
      final response = await _trackingClient.sendMultipleEvents(
        cachedEvents.values.toList(),
        extraData: _extraData,
      );
      if (!response.statusCode.toString().startsWith("2")) {
        print("qqq Tracking=$cachedEvents");
        throw Exception("Tracking error: ${response.body}");
      }
      _print("response=${response.body}");
      await _eventStorage.removeEvents(cachedEvents.values.toList());
      _print("sendAll() success");
    } catch (e, st) {
      _printError(e, st);
      _onError?.call(e, st);
    }
  }

  void updateExtraData(Json newExtra) {
    _extraData = {..._extraData, ...newExtra};
  }

  void addHeader(String key, String value) {
    _trackingClient.addHeader(key, value);
  }

  void clearAllEvents() async {
    await _eventStorage.removeAllEvents();
  }

  void _print(String message) {
    if (debug) print("Tracker -- $message");
  }

  void _printError(Object e, StackTrace st) {
    _print("ERROR! $e: $st");
  }

  set onError(ErrorCallback value) {
    _onError = value;
    _eventStorage.onError = value;
  }
}
