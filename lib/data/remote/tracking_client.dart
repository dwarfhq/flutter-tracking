import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:tracking/domain/event_tracker/track_event.dart';

import '../utils.dart';

class TrackingClient {
  TrackingClient(
    String serviceUrl, {
    this.customEventsKey = "events",
  })  : serviceUrl = Uri.parse(serviceUrl);

  final Uri serviceUrl;
  final client = HttpClient();
  final Map<String, String> _headers = {};

  /// custom key for list of events when sending batch
  final String customEventsKey;

  void addHeader(String key, String value) {
    _headers[key] = value;
  }

  Future<http.Response> sendMultipleEvents(List<TrackEvent> events,
      {Json extraData = const {}}) async {
    final body = {
      ...extraData,
      customEventsKey: events.map((e) => e.data).toList(),
    };
    return http.post(serviceUrl,
        body: jsonEncode(body),
        headers: {"content-type": "application/json", ..._headers});
  }
}
