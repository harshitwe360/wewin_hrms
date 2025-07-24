import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';

import '../../resources/constants.dart';
import 'app_exception.dart';
import 'http_interceptor.dart';

enum MethodType { get, post, put, patch }

class ApiBaseHelper {
  static ApiBaseHelper? _instance;

  ApiBaseHelper._();

  factory ApiBaseHelper() => _instance ??= ApiBaseHelper._();

  // static var client = http.Client();
  static final client = InterceptedClient.build(
    interceptors: [AuthorizationInterceptor()],
    retryPolicy: ExpiredTokenRetryPolicy()
  );

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
      final Map<String, String> headers = getHeaderList(header, paramsString);

      // if(baseUrlType==null || baseUrlType.isEmpty) {
      //   DomainResponse domain = await AuthService.instance.getDomainData();
      //   if (domain.apiGatewayUrl == null || domain.apiGatewayUrl == "") {
      //     AuthService.instance.clearDomainData();
      //     return Future.error(AppConstants.unAuthorization);
      //   }
      //   baseUrlType = AppConstants.operationalUrl;
      // }

      switch (method) {
        case MethodType.get:
          final response = await client.get(
              Uri.parse(
                      "${baseUrlType ?? AppConstants.coreServerUrl}$url$paramsString")
                  .replace(queryParameters: params),
              headers: headers);
          return _returnResponse(response, onlyBodyResponse);
        case MethodType.post:
          final response = await client.post(
              Uri.parse('${baseUrlType ?? AppConstants.coreServerUrl}$url'),
              body: params ?? paramsString,
              headers: headers);
          debugPrint("$response");
          return _returnResponse(response, onlyBodyResponse);
        case MethodType.put:
          final response = await client.put(
              Uri.parse('${baseUrlType ?? AppConstants.coreServerUrl}$url'),
              body: params ?? paramsString,
              headers: headers);
          return _returnResponse(response, onlyBodyResponse);
        case MethodType.patch:
          final response = await client.patch(
              Uri.parse('${baseUrlType ?? AppConstants.coreServerUrl}$url'),
              body: params ?? paramsString,
              headers: headers);
          return _returnResponse(response, onlyBodyResponse);
        default:
          throw Exception('Method Not Found.!');
      }
    } on SocketException catch (e) {
      throw NoInternetException('- ${e.toString()}');
    } on TimeoutException catch (e) {
      throw TimeoutErrorException('Failed to create Response - ${e.toString()}');
    } on FormatException catch (e) {
      throw FormatErrorException(e.toString());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<dynamic> _returnResponse(http.Response response, bool isBodyResponse) async {
    switch (response.statusCode) {
      case 200:
      case 201:
      case 202:
      case 204:
        if(isBodyResponse){
          return response.body.toString();
        }
        return response;
      case 400:
        throw BadRequestException(parseErrorMsg(response.body.toString()));
      case 403:
      // AuthService.instance.clearDomainData();
      // throw ForbiddenException(parseErrorMsg(response.body.toString()));
      case 401:
        throw UnauthorisedException();
      case 404:
        throw MethodNotFoundException(parseErrorMsg(response.body.toString()));
      case 405:
      case 406:
        throw MethodNotAllowedException(parseErrorMsg(response.body.toString()));
      case 500:
        throw InternalErrorException(parseErrorMsg(response.body.toString()));
      case 503:
        throw ServiceUnavailableException(parseErrorMsg(response.body.toString()));
      default:
        throw Exception(parseErrorMsg(response.body.toString(),
            defaultMsg: 'Error with Server with StatusCode : ${response.statusCode}'));
    }
  }

  Map<String, String> getHeaderList(final Map<String, String>? header,
      String? paramsString){

    Map<String, String> headers = {"Accept": "application/json"};
    if (paramsString != null && paramsString.isNotEmpty) {
      headers.addAll({'Content-Type': 'application/json'});
    }
    if (header != null) {
      headers.addAll(header);
    }
    return headers;
  }

  String parseErrorMsg(String response, {String? defaultMsg}) {
    try {
      final result = json.decode(response);
      if (result["errors"] != null && result["errors"][0] != null) {
        return result["errors"][0]["detail"] ?? defaultMsg;
      }
      return defaultMsg ?? "Error with Server with StatusCode";
    } catch(e) {
      return "Error with Server with StatusCode";
    }
  }
}
