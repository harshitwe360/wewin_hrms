import 'package:flutter/cupertino.dart';

import '../../apis/repository/models/auth_response.dart';
import '../auth/auth_service.dart';
import 'api_base_helper.dart';

class RefreshHelper {

  Future<void> refreshToken() async {
    try {

      AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (auth.refreshToken.isEmpty) {
        AuthService.instance.clearUserData();
        return Future(() => false);
      }

      final response = await ApiBaseHelper().request(
          url: "protocol/openid-connect/token",
          method: MethodType.post,
          params: {
            'refresh_token': auth.refreshToken,
            'claims': '{"a": "v"}',
            'grant_type': 'refresh_token',
          });

      AuthResponse refreshAuth = authRespFromJson(response);
      if (refreshAuth.token.isNotEmpty) {
        auth = auth.copyWith(
            token: refreshAuth.token, refreshToken: refreshAuth.refreshToken);
        AuthService.instance.persistCurrentUser(authRespToJson(auth));
        AuthService.instance.persistToken(refreshAuth.token);
        // await GeoLocation.setConfigCustomParam();
        return Future(() => true);
      }
      AuthService.instance.clearDomainData();
      return Future(() => false);
    } on Exception catch (e) {
      debugPrint("Refersh catch : $e");
      // if(e.toString().trim() == "BadRequest:"){
        return Future.error(e);
      // }
    }
  }
}