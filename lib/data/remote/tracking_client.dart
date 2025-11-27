import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tracking/domain/event_tracker/track_event.dart';

import '../utils.dart';

class TrackingClient {
  TrackingClient(
    this.baseUrl, {
    this.headers = const <String, String>{},
    this.customEventsKey = "events",
  });

  final String baseUrl;
  final client = HttpClient();
  final Map<String, String> headers;

  /// custom key for list of events when sending batch
  final String customEventsKey;

  Future<void> sendEvent(TrackEvent event) async {
    final uri = Uri.https(baseUrl, "track");
    await http.post(
      uri,
      headers: headers,
      body: event.toJson(),
    );
  }

  Future<void> sendMultipleEvents(List<TrackEvent> events,
      {Json extraData = const {}}) async {
    final uri = Uri.https(baseUrl, "trackMultiple");
    await http.post(
      uri,
      body: {
        ...extraData,
        customEventsKey: events.map((e) => e.toJson()).toList(),
      },
    );
  }
}
