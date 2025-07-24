import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../core/apis/repository/models/auth_response.dart';
import '../../../../core/apis/repository/models/dd_model.dart';
import '../../../../core/apis/repository/models/domain.dart';
import '../../../../core/apis/repository/models/rest_api_response.dart';
import '../../../../core/config/r.dart';
import '../../../../core/services/auth/auth_service.dart';
import '../../../../core/services/rest_api/api_base_helper.dart';

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

  Future<bool> login({String? username, String? password}) async {
    try {
      if(password==null || username==null){
        return Future(() => false);
      }

      final response = await _restService.request(
          url: "${AppConstants.operationalUrl}HRMSAccounts/Login",
          method: MethodType.post,
          paramsString: json.encode({
            "MobileNo": username,
            "password": password,
          })
      );

      print("loginResponse = $response");
      // ApiResponse responseObj = apiResponseFromJson(response.body.toString());

      final AuthResponse auth = authRespFromJson(response);
      if (auth.token.isNotEmpty) {
        await AuthService.instance.persistCurrentUser(authRespToJson(auth));
        await AuthService.instance.persistToken(auth.token);
        // await AuthService.instance.persistSchema(auth.schema);
        return Future(() => true);
      }
      AuthService.instance.clearUserData();
      return Future.error(auth.message);
    } on Exception catch (e) {
      AuthService.instance.clearUserData();
      return Future.error(e);
    }
  }

  /* -apiGatewayUrl Url Used in below methods- */
  Future<bool> getUserDetails() async {
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (auth.token.isEmpty) {
        AuthService.instance.clearUserData();
        return Future(() => false);
      }

      final result = await _restService.request(
          url: "${AppConstants.operationalUrl}me/who_am_i",
          method: MethodType.get,
          checkAuth: true,
      );

      User userDetails = userRespFromJson(result);

      if (userDetails.userId.isNotEmpty) {
        auth = auth.copyWith(user: userDetails);
        AuthService.instance.persistCurrentUser(authRespToJson(auth));
        return Future(() => true);
      }

      AuthService.instance.clearUserData();
      return Future(() => false);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> logoutRequest() async {
    try {
      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (auth.refreshToken.isEmpty) {
        AuthService.instance.clearUserData();
        return Future(() => true);
      }



      // final response = await _restService.request(
      //     url: "${AppConstants.operationalUrl}protocol/openid-connect/logout",
      //     method: MethodType.post,
      //     header: {
      //       'Authorization': 'Bearer ${auth.token}'
      //     },
      //     params: {
      //       'refresh_token': auth.refreshToken
      //     });
      //
      // if (response.isEmpty) {
        // AuthService.instance.clearUserData();
        return Future(() => true);
      // }
      // return Future(() => false);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> googleLogin({required String email}) async {
      try {

        final authResponse = await _restService.request(
            url: "${AppConstants.operationalUrl}api/googleLoginApi",
            method: MethodType.post,
            params: {"email": email});

        print("loginResponse = $authResponse");

        final AuthResponse resultAuth = authRespFromJson(authResponse);
        // if (auth.success) {
        if (resultAuth.token.isNotEmpty) {
          debugPrint(authRespToJson(resultAuth));
          await AuthService.instance.persistCurrentUser(authRespToJson(resultAuth));
          await AuthService.instance.persistToken(resultAuth.token);
          await AuthService.instance.persistSchema(resultAuth.schema);
          return Future(() => true);
        }
        AuthService.instance.clearUserData();
        return Future.error(resultAuth.message);
      } on Exception catch (e) {
        AuthService.instance.clearUserData();
        return Future.error(e);
      }
  }
}
