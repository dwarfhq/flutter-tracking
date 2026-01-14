import '../../data/utils.dart';

final class PageTrack {
  final String path;
  final int time;
  final Json params;

  PageTrack(this.path, this.time, this.params);

  Json toJson() {
    return {"route": path, "time": time, ...params};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
