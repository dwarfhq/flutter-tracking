import 'package:tracking/data/utils.dart';

class TrackEvent {
  final String eventId;
  final int timeStamp;
  final Map<String, dynamic> parameters;

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

  @override
  bool operator ==(Object other) {
    if (other is! TrackEvent) return false;
    return other.eventId == eventId;
  }
}
