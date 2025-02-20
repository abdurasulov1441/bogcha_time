final class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException({this.message = 'unauthorized'});

  @override
  String toString() {
    return message;
  }
}
