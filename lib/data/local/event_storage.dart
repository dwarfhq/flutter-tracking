import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

class EventStorage {
  final _secureStorage = FlutterSecureStorage();
  final _storageKey = "tracking_events";
  bool _mutex = false;

  Future<void> init() async {
    final exists = await _secureStorage.containsKey(key: _storageKey);
    if (!exists) {
      await _writeToFile([]);
    }
  }

  Future<void> addEvent(TrackEvent event) async {
    await _queue(callback: () async {
      final cachedEvents = await getCachedEvents();
      cachedEvents.add(event);
      final json = cachedEvents.map((e) => e.toJson()).toList();
      await _writeToFile(json);
    });
  }

  Future<void> removeEvents(List<TrackEvent> events) async {
    await _queue(callback: () async {
      final cache = await getCachedEvents();
      final remaining =
          cache.where((event) => !events.contains(event)).toList();
      final json = remaining.map((e) => e.toJson()).toList();
      await _writeToFile(json);
    });
  }

  Future<List<TrackEvent>> getCachedEvents() async {
    final content = await _secureStorage.read(key: _storageKey) ?? "";
    if (content.isEmpty) return [];
    final json = jsonDecode(content);
    if (json is List) {
      return json.map((e) => TrackEvent.fromJson(e)).toList();
    }
    throw Exception("Malformed data");
  }

  Future<void> _writeToFile(Object content) async {
    final encodedJson = jsonEncode(content);
    await _secureStorage.write(key: _storageKey, value: encodedJson);
  }

  Future<void> _queue({required AsyncCallback callback}) async {
    int retry = 0;
    while (_mutex) {
      if (retry > 50) throw TrackingTimeoutException();
      await Future<void>.delayed(Duration(milliseconds: 100));
      retry++;
    }
    _mutex = true;
    await callback();
    _mutex = false;
  }
}
