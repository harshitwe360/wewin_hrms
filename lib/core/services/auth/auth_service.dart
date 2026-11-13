import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

import '../../apis/repository/models/auth_response.dart';
import '../../apis/repository/models/domain.dart';
import '../../resources/constants.dart';
import '../storage/local_storage.dart';

enum RoleType { employee, admin, manager }

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  Future<void> clearAllData() async {
    await StorageService.instance.deleteAllSecureData();
    return;
  }

  Future<void> clearWhoAmIData() async {
    await StorageService.instance
        .deleteSecureData(StorageItem(AppConstants.whoMIDetails, ""));
    return;
  }

  Future<void> clearUserData() async {
    await StorageService.instance
        .deleteSecureData(StorageItem(AppConstants.loginDetails, ""));
    await StorageService.instance
        .deleteSecureData(StorageItem(AppConstants.token, ""));
  }

  Future<void> clearDomainData() async {
    await StorageService.instance
        .deleteSecureData(StorageItem(AppConstants.domainDetails, ""));
    await StorageService.instance
        .deleteSecureData(StorageItem(AppConstants.tenantId, ""));
    await StorageService.instance
        .deleteSecureData(StorageItem(AppConstants.tenantName, ""));
    await clearWhoAmIData();
    return await clearUserData();
  }

  Future<void> persistCurrentUser(String value) async {
    /// write to keystore/keychain
    /// await Future.delayed(Duration(seconds: 1));
    return await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.loginDetails, value));
  }

  Future<void> persistToken(String value) async {
    return await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.token, value));
    // return;
  }

  Future<void> persistSchema(String value) async {
    await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.schema, value));
    return;
  }

  Future<String?> getToken() async {
    return await StorageService.instance.readSecureData(AppConstants.token);
  }

  Future<void> persistServerDeviceId(String value) async {
    return await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.serverDeviceId, value));
  }

  Future<String?> getServerDeviceId() async {
    return await StorageService.instance
        .readSecureData(AppConstants.serverDeviceId);
  }

  Future<String?> getSchema() async {
    return "NAN";
    // return await StorageService.instance.readSecureData(AppConstants.schema);
  }

  Future<void> persistWhoAmIData(String value) async {
    await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.whoMIDetails, value));
    return;
  }

  Future<void> persistDomainData(String value) async {
    await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.domainDetails, value));
    return;
  }

  /*Future<String?> getDomainJson() async {
    return await StorageService.instance.readSecureData(AppConstants.domainDetails);
  }*/

  Future<DomainResponse> getDomainData() async {
    try {
      String domainStr = await StorageService.instance
              .readSecureData(AppConstants.domainDetails) ?? "{}";
      DomainResponse domain = domainParseFromJson(domainStr);
      return Future(() => domain);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Future<void> persistTenantId(String value) async {
    await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.tenantId, value));
    return;
  }

  Future<void> persistTenantName(String value) async {
    await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.tenantName, value));
    return;
  }

  Future<String?> getTenantId() async {
    return await StorageService.instance.readSecureData(AppConstants.tenantId);
  }

  Future<String?> getTenantName() async {
    return await StorageService.instance
        .readSecureData(AppConstants.tenantName);
  }

  Future<bool> isDomainActive() async {
    return await StorageService.instance
        .containsKeyInSecureData(AppConstants.tenantId);
  }

  Future<String?> getUserJson() async {
    return await StorageService.instance
        .readSecureData(AppConstants.loginDetails);
  }

  Future<bool> isUserActive() async {
    return await StorageService.instance
        .containsKeyInSecureData(AppConstants.loginDetails);
  }

  Future<AuthResponse> getCurrentUserData() async {
    try {
      AuthResponse user = AuthResponse();
      await StorageService.instance
          .readSecureData(AppConstants.loginDetails)
          .then((userData) {
        if (userData != null) {
          user = authRespFromJson(userData);
        }
      });
      return Future(() => user);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  /// WinHRMS roles: super_admin, admin, process_admin, manager, employee.
  static RoleType roleFromString(String? role) {
    switch ((role ?? "").toLowerCase()) {
      case "super_admin":
      case "admin":
      case "process_admin":
        return RoleType.admin;
      case "manager":
        return RoleType.manager;
      default:
        return RoleType.employee;
    }
  }

  Future<bool> isAdminUser() async {
    return (await getUserRole) == RoleType.admin;
  }

  /// Role from the stored `/auth/me` user (the WinHRMS JWT carries no
  /// Keycloak `resource_access` claims).
  Future<RoleType> get getUserRole async {
    try {
      final AuthResponse auth = await getCurrentUserData();
      return roleFromString(auth.user?.role);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Future<bool> isWhoMIActive() async {
    return await StorageService.instance
        .containsKeyInSecureData(AppConstants.whoMIDetails);
  }

  Future<Map<String, String>> getIdentityId() async {
    try {
      final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      final Map<String, String> deviceInfo = {"machine_ip": ""};
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        deviceInfo["machine_id"] =
            build.serialNumber.isNotEmpty && build.serialNumber != "unknown"
                ? build.serialNumber
                : build.id; //UUID for Android
        deviceInfo["machine_user"] = (build.display);
        deviceInfo["machine_host_name"] = (build.host.toString());
        deviceInfo["platform"] = "ANDROID";
        deviceInfo["os_name"] = (build.device.toString());
        deviceInfo["os_version"] = (build.version.release.toString());
      } else if (Platform.isIOS) {
        var data = await deviceInfoPlugin.iosInfo;
        deviceInfo["machine_host_name"] = "";
        deviceInfo["machine_id"] =
            (data.identifierForVendor) ?? ""; //UUID for iOS
        deviceInfo["machine_user"] = (data.name);
        deviceInfo["platform"] = "IOS";
        deviceInfo["os_version"] = (data.systemVersion);
        deviceInfo["os_name"] = (data.systemName);
      }
      return Future(() => deviceInfo);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  Map<String, dynamic> decodeJWTBase64(String code) {
    String normalizedSource = base64Url.normalize(code.split(".")[1]);
    return json.decode(utf8.decode(base64Url.decode(normalizedSource)));
    /*print("resource_access = ${data["resource_access"]}");
    print(data["resource_access"]["pvvb-wkzr-rwzr"]["roles"]);
    // print("Role === ${}");
    return utf8.decode(base64Url.decode(normalizedSource));*/
  }

  Future<bool> isFreshInstall() async {
    return !(await StorageService.instance
        .containsKeyInSecureData(AppConstants.freshInstall));
  }

  Future<void> persistFreshInstall(String value) async {
    return await StorageService.instance
        .writeSecureData(StorageItem(AppConstants.freshInstall, value));
  }
}
