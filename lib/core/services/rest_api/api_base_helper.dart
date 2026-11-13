import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';

import '../../resources/constants.dart';
import '../auth/auth_service.dart';
import 'app_exception.dart';
import 'http_interceptor.dart';

enum MethodType { get, post, put, patch }

class ApiBaseHelper {
  static ApiBaseHelper? _instance;

  ApiBaseHelper._();

  factory ApiBaseHelper() => _instance ??= ApiBaseHelper._();

  // No retry policy: neither backend exposes a token-refresh route.
  // A 401 from WinHRMS clears the session and callers route to login.
  static final client = InterceptedClient.build(
    interceptors: [AuthorizationInterceptor()],
  );

  /// [baseUrlType] defaults to the legacy backend ([AppConstants.coreServerUrl]);
  /// pass `ApiEndpoints.baseUrl` for WinHRMS calls.
  /// [checkAuth] false sends the request without a bearer token.
  Future<dynamic> request({
      required String url, required MethodType method,
      String? paramsString = "",
      String? baseUrlType,
      final Map<String, dynamic>? params,
      final Map<String, String>? header,
      bool checkAuth = false,
      bool onlyBodyResponse = true
  }) async {
    try {
      final Map<String, String> headers =
          getHeaderList(header, paramsString, checkAuth: checkAuth);
      final String base = baseUrlType ?? AppConstants.coreServerUrl;

      final http.Response response;
      switch (method) {
        case MethodType.get:
          final Uri uri = Uri.parse("$base$url$paramsString");
          response = await client
              .get(params == null
                  ? uri
                  : uri.replace(queryParameters: params
                      .map((k, v) => MapEntry(k, v?.toString()))),
                  headers: headers)
              .timeout(AppConstants.requestTimeout);
          break;
        case MethodType.post:
          response = await client
              .post(Uri.parse('$base$url'),
                  body: params ?? paramsString, headers: headers)
              .timeout(AppConstants.requestTimeout);
          break;
        case MethodType.put:
          response = await client
              .put(Uri.parse('$base$url'),
                  body: params ?? paramsString, headers: headers)
              .timeout(AppConstants.requestTimeout);
          break;
        case MethodType.patch:
          response = await client
              .patch(Uri.parse('$base$url'),
                  body: params ?? paramsString, headers: headers)
              .timeout(AppConstants.requestTimeout);
          break;
      }
      return await _returnResponse(response, onlyBodyResponse,
          isWinHrms: base == AppConstants.winHrmsServerUrl);
    } on AppException {
      rethrow;
    } on SocketException catch (e) {
      throw NoInternetException('- ${e.toString()}');
    } on TimeoutException catch (e) {
      throw TimeoutErrorException('Failed to create Response - ${e.toString()}');
    } on FormatException catch (e) {
      throw FormatErrorException(e.toString());
    } on http.ClientException catch (e) {
      throw NoInternetException('- ${e.message}');
    }
  }

  Future<dynamic> _returnResponse(http.Response response, bool isBodyResponse,
      {bool isWinHrms = false}) async {
    final String body = response.body.toString();
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        if(isBodyResponse){
          return body;
        }
        return response;
      case 400:
        throw BadRequestException(parseErrorMsg(body));
      case 401:
        // WinHRMS: token invalid, expired or invalidated. No refresh route
        // exists, so drop the local session.
        if (isWinHrms) {
          await AuthService.instance.clearUserData();
        }
        throw UnauthorisedException(parseErrorMsg(body, defaultMsg: ""));
      case 403:
        // WinHRMS: user inactive or tenant suspended.
        throw ForbiddenException(parseErrorMsg(body,
            defaultMsg: "Access denied. Your account or company may be inactive."));
      case 404:
        throw MethodNotFoundException(parseErrorMsg(body));
      case 405:
      case 406:
        throw MethodNotAllowedException(parseErrorMsg(body));
      case 422:
        throw ValidationException(parseErrorMsg(body));
      case 429:
        // WinHRMS rate-limits login attempts.
        throw TooManyRequestsException(parseErrorMsg(body,
            defaultMsg: "Too many attempts. Please try again later."));
      case 500:
        throw InternalErrorException(parseErrorMsg(body));
      case 503:
        throw ServiceUnavailableException(parseErrorMsg(body));
      default:
        throw AppException(parseErrorMsg(body,
            defaultMsg: 'Error with Server with StatusCode : ${response.statusCode}'),
            "Error");
    }
  }

  Map<String, String> getHeaderList(final Map<String, String>? header,
      String? paramsString, {bool checkAuth = true}){

    Map<String, String> headers = {"Accept": "application/json"};
    if (paramsString != null && paramsString.isNotEmpty) {
      headers.addAll({'Content-Type': 'application/json'});
    }
    if (!checkAuth) {
      headers[AuthorizationInterceptor.skipAuthHeader] = "1";
    }
    if (header != null) {
      headers.addAll(header);
    }
    return headers;
  }

  /// Supports FastAPI (`{"detail": "..."}` or `{"detail": [{"msg": ...}]}`),
  /// legacy (`{"errors": [{"detail": ...}]}`) and `{"message": ...}` bodies.
  String parseErrorMsg(String response, {String? defaultMsg}) {
    final String fallback = defaultMsg ?? "Error with Server with StatusCode";
    try {
      final dynamic result = json.decode(response);
      if (result is! Map) return fallback;

      final dynamic detail = result["detail"];
      if (detail is String && detail.isNotEmpty) return detail;
      if (detail is List && detail.isNotEmpty) {
        final List<String> msgs = detail
            .whereType<Map>()
            .map((e) => e["msg"]?.toString() ?? "")
            .where((m) => m.isNotEmpty)
            .toList();
        if (msgs.isNotEmpty) return msgs.join("\n");
      }

      final dynamic errors = result["errors"];
      if (errors is List && errors.isNotEmpty && errors.first is Map) {
        final dynamic d = errors.first["detail"];
        if (d != null) return d.toString();
      }

      final dynamic message = result["message"];
      if (message is String && message.isNotEmpty) return message;

      return fallback;
    } catch(e) {
      debugPrint("parseErrorMsg: $e");
      return fallback;
    }
  }
}
