import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

class EventStorage {
  final String _storageName = "tracking_events.json";
  late final String _storagePath;
  bool mutex = false;

  Future<void> init() async {
    final Directory cacheDir = await getApplicationCacheDirectory();
    _storagePath = "${cacheDir.path}/$_storageName";
    final file = File(_storagePath);
    final exists = await file.exists();
    if (!exists) {
      await file.create(recursive: true);
      await _writeToFile(jsonEncode([]));
    }
  }

  Future<void> addEvent(TrackEvent event) async {
    await _queue(callback: () async {
      final cachedEvents = await getCachedEvents();
      cachedEvents.add(event);
      final json = cachedEvents.map((e) => e.toJson()).toList();
      await _writeToFile(jsonEncode(json));
    });
  }

  Future<void> removeEvents(List<TrackEvent> events) async {
    await _queue(callback: () async {
      final cache = await getCachedEvents();
      final remaining =
          cache.where((event) => !events.contains(event)).toList();
      final json = remaining.map((e) => e.toJson()).toList();
      await _writeToFile(jsonEncode(json));
    });
  }

  Future<List<TrackEvent>> getCachedEvents() async {
    final file = File(_storagePath);
    final content = await file.readAsString();
    if (content.isEmpty) return [];
    final json = jsonDecode(content);
    if (json is List) {
      if (json.isEmpty) return [];
      return json.map((e) => TrackEvent.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _writeToFile(String content) async {
    final file = File(_storagePath);
    var sink = file.openWrite();
    sink.write(content);
    await sink.flush();
    await sink.close();
  }

  Future<void> _queue({required AsyncCallback callback}) async {
    int retry = 0;
    while (mutex) {
      if (retry > 50) throw TrackingTimeoutException();
      await Future<void>.delayed(Duration(milliseconds: 100));
      retry++;
    }
    mutex = true;
    await callback();
    mutex = false;
  }
}
