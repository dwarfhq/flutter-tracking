import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tracking/domain/event_tracker/track_event.dart';

import '../utils.dart';

class TrackingClient {
  TrackingClient(
    String serviceUrl, {
    this.headers = const <String, String>{},
    this.customEventsKey = "events",
  }) : serviceUrl = Uri.parse(serviceUrl);

  final Uri serviceUrl;
  final client = HttpClient();
  final Map<String, String> headers;

  /// custom key for list of events when sending batch
  final String customEventsKey;

  Future<void> sendMultipleEvents(List<TrackEvent> events,
      {Json extraData = const {}}) async {
    await http.post(
      serviceUrl,
      body: {
        ...extraData,
        customEventsKey: events.map((e) => e.toJson()).toList(),
      },
    );
  }
}
