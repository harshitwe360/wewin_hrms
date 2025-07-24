import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:http_interceptor/http_interceptor.dart';

import '../auth/auth_service.dart';
import 'refresh_helper.dart';

class AuthorizationInterceptor implements InterceptorContract {

  // We need to intercept request
  @override
  Future<BaseRequest> interceptRequest({required BaseRequest request}) async {
    try {

      // Clear previous header and update it with updated token
      // data.headers.clear();

      String? tenantId = await AuthService.instance.getTenantId();
      if (tenantId != null && tenantId.isNotEmpty) {
        request.headers['X-Tenant-Id'] = tenantId;
      }

      final String? token = await AuthService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
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


//2 Retry Policy
//This is where request retry
class ExpiredTokenRetryPolicy extends RetryPolicy {

  //Number of retry
  @override
  int get maxRetryAttempts => 1;

  @override
  Future<bool> shouldAttemptRetryOnResponse(BaseResponse response) async {
    //This is where we need to update our token on 401 response
    // print("shouldAttemptRetryOnResponse : ====================");
    if (response.statusCode == 401 || response.statusCode == 403) {
      //Refresh your token here. Make refresh token method where you get new token from
      //API and set it to your local data
      debugPrint("AuthorizationInterceptor : ${response.statusCode}");
      await RefreshHelper().refreshToken();  //Find bellow the code of this function
      return true;
    }
    return false;
  }
}