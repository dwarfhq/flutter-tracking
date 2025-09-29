import 'package:tracking/data/utils.dart';
import 'package:tracking/domain/route_time_tracker/page_track.dart';

class TrackEvent {
  final String eventId;
  final int timeStamp;
  final Json parameters;

  TrackEvent({
    required this.timeStamp,
    required this.eventId,
    required this.parameters,
  });

  Json toJson() {
    return {
      "event_id": eventId,
      "timestamp": timeStamp,
      "params": parameters,
    };
  }

  static TrackEvent fromJson(Json json) {
    return TrackEvent(
      timeStamp: json["timestamp"],
      eventId: json["event_id"],
      parameters: json["params"],
    );
  }

  static TrackEvent fromScreen(PageTrack event) {
    return TrackEvent(timeStamp: DateTime.now().millisecondsSinceEpoch, eventId: "screen", parameters: event.toJson());
  }

  @override
  String toString() {
    return "TrackEvent: $eventId, $parameters";
    return super.toString();
  }

  @override
  bool operator ==(Object other) {
    if (other is! TrackEvent) return false;
    return other.eventId == eventId;
  }
}
