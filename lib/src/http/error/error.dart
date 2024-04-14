part of http;

class ErrorWithMessage extends Error {
  final String _message;
  ErrorWithMessage(this._message);

  @override
  String toString() {
    return _message;
  }
}

class TCPError extends ErrorWithMessage {
  TCPError(String message) : super(message);
}

class UDPError extends ErrorWithMessage {
  UDPError(String message) : super(message);
}
