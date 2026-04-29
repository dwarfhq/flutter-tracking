import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tracking/data/tracking_exceptions.dart';
import 'package:tracking/domain/event_tracker/track_event.dart';

import '../utils.dart';

class EventStorage {
  final _secureStorage = FlutterSecureStorage();
  final String _storageKey;
  ErrorCallback? _onError;
  bool _mutex = false;

  EventStorage(this._storageKey);

  Future<void> init() async {
    final exists = await _secureStorage.containsKey(key: _storageKey);
    if (!exists) {
      await _writeToFile([]);
    }
  }

  Future<void> addEvent(TrackEvent event) async {
    await _queue(callback: () async {
      final cachedEvents = await getCachedEvents();
      cachedEvents[event.cacheId] = event;
      await _writeToFile(cachedEvents.values.toList());
    });
  }

  Future<void> removeEvents(List<TrackEvent> events) async {
    await _queue(callback: () async {
      final cache = await getCachedEvents();
      for (final event in events) {
        cache.remove(event.cacheId);
      }
      final entries = cache.map((key, value) => MapEntry(key, value.toJson()));
      await _writeToFile(entries.values.toList());
    });
  }

  Future<void> removeAllEvents() async {
    await _writeToFile([]);
  }

  Future<Map<String, TrackEvent>> getCachedEvents() async {
    final content = await _secureStorage.read(key: _storageKey) ?? "";
    if (content.isEmpty) return {};
    final json = jsonDecode(content);
    if (json is List) {
      final ls = json.map((e) => TrackEvent.fromJson(e)).toList();
      final entries = ls.map((event) => MapEntry(event.cacheId, event));
      return Map.fromEntries(entries);
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
    try {
      await callback();
    } catch (e, st) {
      _onError?.call(e, st);
    } finally {
      _mutex = false;
    }
  }

  set onError(ErrorCallback onError) {
    _onError = onError;
  }
}
