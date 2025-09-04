abstract class TrackingException {
  final String message;

  TrackingException({required this.message});
}

final class TrackingTimeoutException extends TrackingException {
  TrackingTimeoutException() : super(message: "Local caching timed out");
}

final class TrackingNotInitialisedException extends TrackingException {
  TrackingNotInitialisedException()
      : super(
          message:
              "Plugin not initialised. Remember to call initialize() after instantiation.",
        );
}
