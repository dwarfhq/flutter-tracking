import 'package:tracking/data/local/event_storage.dart';
import 'package:tracking/data/remote/tracking_client.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

class Tracker {
  final _eventStorage = EventStorage();
  final TrackingClient _trackingClient;
  final int batchSize;

  Tracker({required String serviceBaseUrl, this.batchSize = 5})
      : _trackingClient = TrackingClient(serviceBaseUrl);

  Future<void> initialize() async {
    await _eventStorage.init();
  }

  Future<void> track(TrackEvent event) async {
    await _eventStorage.addEvent(event);
    final cachedEvents = await _eventStorage.readCache();
    print("qqq events = ${cachedEvents.length}");
    if (cachedEvents.length > batchSize - 1) {
      await _trackingClient.sendMultipleEvents(cachedEvents);
      await _eventStorage.removeEvents(cachedEvents);
      final rem = await _eventStorage.readCache();
      print("qqq events = ${rem.length}");
    }
  }
}
