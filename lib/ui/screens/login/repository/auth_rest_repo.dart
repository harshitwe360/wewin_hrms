import 'dart:convert';


import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/apis/repository/models/dd_model.dart';
import '../../../../core/apis/repository/models/rest_api_response.dart';
import '../../../../core/config/r.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/apis/api_endpoints.dart';
import '../../../../core/services/rest_api/api_base_helper.dart';
import '../../../../core/services/rest_api/app_exception.dart';

class AuthRepository {

  static AuthRepository? _instance;

  AuthRepository._();

  factory AuthRepository() => _instance ??= AuthRepository._();

  final ApiBaseHelper _restService = ApiBaseHelper();
  static const String errorStr = "unAuthorization";

  Future signUp({required Map<String, dynamic> variables}) async {
    try {
      final response = await _restService.request(
          url: "${AppConstants.operationalUrl}HRMSAccounts/SignUp",
          method: MethodType.post,
          onlyBodyResponse: false,
          paramsString: json.encode(variables)
      );

      ApiResponse responseObj = apiResponseFromJson(response.body.toString());
      if (responseObj.status) {
        return Future(() => responseObj);
      }
      AuthService.instance.clearUserData();
      return Future.error("Error: ${responseObj.message}");
    } on Exception catch (e) {
      AuthService.instance.clearUserData();
      return Future.error(e);
    }
  }

  Future sentOTP({required Map<String, dynamic> variables}) async {
    try {

      final result = await _restService.request(
          url: "${AppConstants.operationalUrl}HRMSAccounts/SendOTP",
          method: MethodType.post,
          onlyBodyResponse: false,
          paramsString: json.encode(variables)
      );

      ApiResponse responseObj = apiResponseFromJson(result.body.toString());
      if (responseObj.status) {
        return Future(() => responseObj);
      }
      AuthService.instance.clearUserData();
      return Future.error("Server Error with StatusCode: ${result.statusCode}");
    } on Exception catch (e) {
      AuthService.instance.clearUserData();
      return Future.error(e);
    }
  }

  Future verifyOTP({required Map<String, dynamic> variables}) async {
    try {

      final result = await _restService.request(
          url: "${AppConstants.operationalUrl}HRMSAccounts/VerifyOTP",
          method: MethodType.post,
          onlyBodyResponse: false,
          paramsString: json.encode(variables)
      );

      ApiResponse responseObj = apiResponseFromJson(result.body.toString());
      if (responseObj.status) {
        // User auth = await AuthService.instance.getCurrentUserData();
        // if (auth.userId == null || auth.userId!.isEmpty) {
        //   AuthService.instance.clearUserData();
        //   return Future.error("Unable to process, Please re-open the app.!");
        // }
        // auth = auth.copyWith(isVerified: true);
        // await AuthService.instance.persistCurrentUser(auth.toRawJson());
        return Future(() => responseObj);
      }
      // AuthService.instance.clearUserData();
      return Future.error("Server Error with StatusCode: ${result.statusCode}");
    } on Exception catch (e) {
      // AuthService.instance.clearUserData();
      return Future.error(e);
    }
  }

  Future getDropDownList({Map<String, dynamic>? variables}) async {
    try {
      final result = await _restService.request(
          url: "${AppConstants.operationalUrl}EmployeeAttendance/GetDDLData",
          method: MethodType.post,
          // checkAuth: true,
          paramsString: json.encode(variables)
      );

      ApiResponse response = apiResponseFromJson(result);
      if (response.status) {
        final List<DdModel> list = ddListFromObjJson(response.data);
        return Future(() => list);
      }
      return Future.error(response.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  /// WinHRMS `POST /api/auth/login/json`. Tenant is pinned to
  /// [AppConstants.defaultTenantSlug]. On success the token and the
  /// `/auth/me` user are persisted.
  Future<bool> login({required String email, required String password}) async {
    try {
      final String body = await _restService.request(
          baseUrlType: ApiEndpoints.baseUrl,
          url: ApiEndpoints.login,
          method: MethodType.post,
          paramsString: json.encode({
            "email": email.trim(),
            "password": password,
            "tenant_slug": AppConstants.defaultTenantSlug,
          }));
      await _persistSession(AuthResponse.fromJson(json.decode(body)));
      return true;
    } on UnauthorisedException catch (e) {
      await AuthService.instance.clearUserData();
      return Future.error(_detailOr(e.detail, "Invalid email or password."));
    } on AppException catch (e) {
      await AuthService.instance.clearUserData();
      return Future.error(e.message);
    } on Exception catch (e) {
      await AuthService.instance.clearUserData();
      return Future.error(e);
    }
  }

  /// WinHRMS `POST /api/auth/otp/request`. Returns the server message and
  /// the code's lifetime in seconds.
  Future<({String message, int expiresInSeconds})> requestLoginOtp(
      {required String email}) async {
    final String body = await _restService.request(
        baseUrlType: ApiEndpoints.baseUrl,
        url: ApiEndpoints.otpRequest,
        method: MethodType.post,
        paramsString: json.encode({
          "email": email.trim(),
          "tenant_slug": AppConstants.defaultTenantSlug,
        }));
    final Map<String, dynamic> map = json.decode(body);
    return (
      message: (map["message"] ?? "").toString(),
      expiresInSeconds: (map["expires_in_seconds"] as num?)?.toInt() ?? 0,
    );
  }

  /// WinHRMS `POST /api/auth/otp/verify`. Persists the session on success.
  Future<bool> verifyLoginOtp({required String email, required String otp}) async {
    try {
      final String body = await _restService.request(
          baseUrlType: ApiEndpoints.baseUrl,
          url: ApiEndpoints.otpVerify,
          method: MethodType.post,
          paramsString: json.encode({
            "email": email.trim(),
            "otp": otp,
            "tenant_slug": AppConstants.defaultTenantSlug,
          }));
      await _persistSession(AuthResponse.fromJson(json.decode(body)));
      return true;
    } on UnauthorisedException catch (e) {
      await AuthService.instance.clearUserData();
      return Future.error(_detailOr(e.detail, "Invalid or expired OTP."));
    }
  }

  /// WinHRMS `POST /api/auth/forgot-password`: emails a reset link
  /// (`…/login?reset_token=…`). The server answers the same whether or not
  /// the account exists. Returns its message.
  Future<String> forgotPassword({required String email}) async {
    final String body = await _restService.request(
        baseUrlType: ApiEndpoints.baseUrl,
        url: ApiEndpoints.forgotPassword,
        method: MethodType.post,
        paramsString: json.encode({
          "email": email.trim(),
          "tenant_slug": AppConstants.defaultTenantSlug,
        }));
    return _message(body,
        "If an account exists for that email, a password reset link has been sent.");
  }

  /// WinHRMS `POST /api/auth/reset-password`. [token] is the `reset_token`
  /// from the emailed link (≥ 20 chars); [newPassword] is 8–128 chars.
  Future<String> resetPassword(
      {required String token, required String newPassword}) async {
    final String body = await _restService.request(
        baseUrlType: ApiEndpoints.baseUrl,
        url: ApiEndpoints.resetPassword,
        method: MethodType.post,
        paramsString: json.encode({
          "token": token.trim(),
          "new_password": newPassword,
        }));
    return _message(body, "Password updated. You can now log in.");
  }

  /// Accepts the full emailed link or the bare token; returns the token.
  static String extractResetToken(String input) {
    final String s = input.trim();
    final Uri? uri = Uri.tryParse(s);
    final String? fromLink = uri?.queryParameters["reset_token"] ??
        uri?.queryParameters["token"];
    return (fromLink ?? s).trim();
  }

  String _message(String body, String fallback) {
    try {
      final dynamic m = json.decode(body);
      final String? msg = m is Map ? m["message"]?.toString() : null;
      return (msg == null || msg.isEmpty) ? fallback : msg;
    } catch (_) {
      return fallback;
    }
  }

  /// WinHRMS `GET /api/auth/me` with the stored token.
  Future<User> fetchMe() async {
    final String body = await _restService.request(
        baseUrlType: ApiEndpoints.baseUrl,
        url: ApiEndpoints.me,
        method: MethodType.get,
        checkAuth: true);
    return User.fromMe(json.decode(body));
  }

  /// Server-side token check used at app start. Refreshes the stored user.
  /// Returns false (and clears the session) when the token is rejected;
  /// rethrows network errors so the caller can decide to stay offline.
  Future<bool> validateSession() async {
    final String? token = await AuthService.instance.getToken();
    if (token == null || token.isEmpty) {
      await AuthService.instance.clearUserData();
      return false;
    }
    try {
      final User user = await fetchMe();
      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      await AuthService.instance
          .persistCurrentUser(authRespToJson(auth.copyWith(token: token, user: user)));
      return true;
    } on UnauthorisedException {
      await AuthService.instance.clearUserData();
      return false;
    } on ForbiddenException {
      await AuthService.instance.clearUserData();
      rethrow;
    }
  }

  Future<void> _persistSession(AuthResponse token) async {
    if (token.token.isEmpty) {
      throw BadRequestException("Login response did not include a token.");
    }
    // /auth/me needs the bearer, so store it first.
    await AuthService.instance.persistToken(token.token);
    final User user = await fetchMe();
    if (!user.isActive) {
      throw ForbiddenException("Your account is inactive.");
    }
    await AuthService.instance
        .persistCurrentUser(authRespToJson(token.copyWith(user: user)));
  }

  String _detailOr(String? detail, String fallback) =>
      detail == null || detail.isEmpty ? fallback : detail;
}
