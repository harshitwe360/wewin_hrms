class AppException implements Exception {
  final String? _message;
  final dynamic _prefix;
  AppException([this._message, this._prefix]);

  /// Server/user-facing message without the "Prefix:" label.
  String get message {
    final String m = (_message ?? "").trim();
    return m.isNotEmpty ? m : toString();
  }
  @override
  String toString() {
    //return '{"status":false, "message": "$_prefix$_message", "data":{}}';
    return ("$_prefix: ${_message ?? ""}").trim();
  }
}
/* response code 400 */
class BadRequestException extends AppException {
  BadRequestException([String? message]) : super(message, "BadRequest");
}

/* response code 401 */
class UnauthorisedException extends AppException {
  /// Server's `detail` (e.g. "Invalid tenant or credentials"). Kept out of
  /// toString() so blocs can still compare against AppConstants.unAuthorization.
  final String? detail;

  UnauthorisedException([this.detail]) : super(null, "Unauthorised");
}

/* response code 403 */
class ForbiddenException extends AppException {
  ForbiddenException([String? message])
      : super(message, "Forbidden");
}

/* response code 429 */
class TooManyRequestsException extends AppException {
  TooManyRequestsException([String? message]) : super(message, "Too many requests");
}

/* response code 422 */
class ValidationException extends AppException {
  ValidationException([String? message]) : super(message, "Invalid input");
}

/* response code 404 */
class MethodNotFoundException extends AppException {
  MethodNotFoundException([String? message]) : super(message, "NotFound");
}

/* response code 405 */
class MethodNotAllowedException extends AppException {
  MethodNotAllowedException([String? message]) : super(message, "NotAllowed");
}

/* response code 408 */
class TimeoutErrorException extends AppException {
  TimeoutErrorException([String? message]) : super(message, "Timeout");
}

/* response code 500 */
class InternalErrorException extends AppException {
  InternalErrorException([String? message]) : super(message, "InternalServerError");
}

/* response code 503 */
class ServiceUnavailableException extends AppException {
  ServiceUnavailableException([String? message])
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


