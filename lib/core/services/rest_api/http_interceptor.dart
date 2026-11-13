import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../auth/auth_service.dart';

class AuthorizationInterceptor implements InterceptorContract {

  /// Marker set by ApiBaseHelper when `checkAuth` is false. Stripped here and
  /// never sent; the request goes out without a bearer token.
  static const String skipAuthHeader = "X-Skip-Auth";

  // We need to intercept request
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {

      // Clear previous header and update it with updated token
      // data.headers.clear();

      // Tenant is resolved from the bearer token (login sends tenant_slug),
      // so no X-Tenant-Id header is needed.
      final bool skipAuth = request.headers.remove(skipAuthHeader) != null;
      if (!skipAuth) {
        final String? token = await AuthService.instance.getToken();
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }

      // data.headers['content-type'] = 'application/json';
    } catch (e) {
      debugPrint(e.toString());
    }

    debugPrint("url : ${request.url.toString()}");
    // debugPrint("body : ${request.body}");

    return request;
  }

  // Currently we do not have any need to intercept response
  @override
  Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
    debugPrint("Response status code : ${response.statusCode.toString()}");
    debugPrint("Request : ${response.request.toString()}");
    // debugPrint("Response data : ${data.toString()}");
    return response;
  }

  // @override
  // Future<BaseResponse> interceptResponse({required BaseResponse response}) async {
  //   debugPrint("Response status code : ${response.statusCode.toString()}");
  //   // debugPrint("Request : ${response.request.toString()}");
  //   // debugPrint("Response data : ${response.toString()}");
  //   return response;
  // }

  @override
  FutureOr<bool> shouldInterceptRequest() {
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    return true;
  }
}
