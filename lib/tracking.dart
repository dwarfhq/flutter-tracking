import 'package:tracking/data/local/event_storage.dart';
import 'package:tracking/data/remote/tracking_client.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

class Tracker {
  final _eventStorage = EventStorage();
  final TrackingClient _trackingClient;
  final int batchSize;
  final bool debug;
  bool _isInitialised = false;

  Tracker({
    required String serviceBaseUrl,
    Map<String, String> clientHeaders = const {},
    this.debug = false,
    this.batchSize = 5,
  }) : _trackingClient = TrackingClient(
          serviceBaseUrl,
          clientHeaders,
        );

  Future<void> initialize() async {
    try {
      await _eventStorage.init();
      _isInitialised = true;
      await sendAll();
    } catch (e, st) {
      _printError(e, st);
    }
  }

  Future<void> track(TrackEvent event) async {
    if (!_isInitialised) throw TrackingNotInitialisedException();
    try {
      _print("track($event)");
      await _eventStorage.addEvent(event);
      final cachedEvents = await _eventStorage.getCachedEvents();
      if (cachedEvents.length >= batchSize) {
        await sendAll();
      }
    } catch (e, st) {
      _printError(e, st);
    }
  }

  Future<void> sendAll() async {
    if (!_isInitialised) throw TrackingNotInitialisedException();
    try {
      final cachedEvents = await _eventStorage.getCachedEvents();
      _print("sendAll(), len=${cachedEvents.length}");
      await _trackingClient.sendMultipleEvents(cachedEvents);
      await _eventStorage.removeEvents(cachedEvents);
      _print("sendAll() success");
    } catch (e, st) {
      _printError(e, st);
    }
  }

  void _print(String message) {
    if (debug) print("Tracker -- $message");
  }

  void _printError(Object e, StackTrace st) {
    _print("ERROR! $e: $st");
  }
}
