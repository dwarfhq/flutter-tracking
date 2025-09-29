import '../../data/utils.dart';

final class PageTrack {
  final String path;
  final int time;

  PageTrack(this.path, this.time);

  Json toJson() {
    return {"route": path, "time": time};
  }

  @override
  String toString() {
    return toJson().toString();
  }
}
