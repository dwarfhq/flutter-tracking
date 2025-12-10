import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tracking/domain/event_tracker/track_event.dart';

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
      {Map<String, String> extraData = const {}}) async {
    await http.post(
      serviceUrl,
      body: {
        ...extraData,
        customEventsKey: jsonEncode(events.map((e) => e.toJson()).toList()),
      },
    );
  }
}
