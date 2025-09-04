import 'package:tracking/data/local/event_storage.dart';
import 'package:tracking/data/remote/tracking_client.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

class Tracker {
  final _eventStorage = EventStorage();
  final TrackingClient _trackingClient;
  final int batchSize;
  bool isInitialised = false;

  Tracker({required String serviceBaseUrl, this.batchSize = 5})
      : _trackingClient = TrackingClient(serviceBaseUrl);

  Future<void> initialize() async {
    await _eventStorage.init();
    isInitialised = true;
    await sendAll();
  }

  Future<void> track(TrackEvent event) async {
    if (!isInitialised) throw TrackingNotInitialisedException();
    await _eventStorage.addEvent(event);
    final cachedEvents = await _eventStorage.getCachedEvents();
    if (cachedEvents.length >= batchSize) {
      await _trackingClient.sendMultipleEvents(cachedEvents);
      await _eventStorage.removeEvents(cachedEvents);
    }
  }

  Future<void> sendAll() async {
    if (!isInitialised) throw TrackingNotInitialisedException();
    final cachedEvents = await _eventStorage.getCachedEvents();
    await _trackingClient.sendMultipleEvents(cachedEvents);
    await _eventStorage.removeEvents(cachedEvents);
  }
}
