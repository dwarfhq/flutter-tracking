import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tracking/domain/event_tracker/track_event.dart';

class TrackingClient {
  TrackingClient(this.baseUrl);
  final String baseUrl;
  final client = HttpClient();

  Future<void> sendEvent(TrackEvent event) async {
    final uri = Uri.https(baseUrl, "track");
    await http.post(
      uri,
      body: event.toJson(),
    );
  }

  Future<void> sendMultipleEvents(List<TrackEvent> events) async {
    final uri = Uri.https(baseUrl, "trackMultiple");
    await http.post(
      uri,
      body: {
        "events": events.map((e) => e.toJson()).toList(),
      },
    );
  }
}
