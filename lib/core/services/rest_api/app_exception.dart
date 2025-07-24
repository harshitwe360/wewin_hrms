class AppException implements Exception {
  final String? _message;
  final dynamic _prefix;
  AppException([this._message, this._prefix]);
  @override
  String toString() {
    //return '{"status":false, "message": "$_prefix$_message", "data":{}}';
    return ("$_prefix: ${_message ?? ""}").trim();
  }
}
/* response code 400 */
class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "BadRequest");
}

/* response code 401 */
class UnauthorisedException extends AppException {
  UnauthorisedException([message])
      // : super(message, "");
      : super(message, "Unauthorised");
}

/* response code 403 */
class ForbiddenException extends AppException {
  ForbiddenException([message])
      : super(message, "");
      // : super(message, "Forbidden: ");
}

/* response code 404 */
class MethodNotFoundException extends AppException {
  MethodNotFoundException([message]) : super(message, "NotFound");
}

/* response code 405 */
class MethodNotAllowedException extends AppException {
  MethodNotAllowedException([String? message]) : super(message, "NotAllowed");
}

/* response code 408 */
class TimeoutErrorException extends AppException {
  TimeoutErrorException([message]) : super(message, "Timeout");
}

/* response code 500 */
class InternalErrorException extends AppException {
  InternalErrorException([message]) : super(message, "InternalServerError");
}

/* response code 503 */
class ServiceUnavailableException extends AppException {
  ServiceUnavailableException([message])
      : super(message, "ServiceUnavailable");
}


class FormatErrorException extends AppException {
  FormatErrorException([String? message])
      : super(message, "Bad response format");
}

class NoInternetException extends AppException {
  NoInternetException([String? message])
      : super(message, "No Internet");
}


