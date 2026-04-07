import 'package:tracking/data/utils.dart';

class TrackEvent  {
  final String cacheId;
  final Json data;

  const TrackEvent({
    required this.data,
    required this.cacheId,
  });

  Json toJson() {
    return {"cache_id": cacheId, ...data};
  }

  static TrackEvent fromJson(Json json) {
    return TrackEvent(
      cacheId: json["cache_id"] ?? "",
      data: json,
    );
  }

  @override
  String toString() {
    return "TrackEvent: $cacheId, $data";
  }

  @override
  bool operator ==(Object other) {
    if (other is! TrackEvent) return false;
    return other.cacheId == cacheId;
  }
}
