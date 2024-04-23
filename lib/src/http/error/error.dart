part of '../http.dart';

class ErrorWithMessage extends Error {
  final String _message;
  ErrorWithMessage(this._message);

  @override
  String toString() {
    return _message;
  }
}

class TCPError extends ErrorWithMessage {
  TCPError(super.message);
}

class UDPError extends ErrorWithMessage {
  UDPError(super.message);
}
