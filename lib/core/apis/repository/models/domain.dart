import 'dart:convert';

DomainResponse domainParseFromJson(String str) => DomainResponse.fromJson(json.decode(str));

String domainParseToJson(DomainResponse data) => json.encode(data.toJson());

class DomainResponse {
  String? tenantId;
  String? tenantName;
  String? baseDomain;
  String? apiGatewayUrl;
  String? coreServiceUrl;
  String? apiKeycloakUrl;
  String? apiKeycloakRealm;
  List? errors;

  DomainResponse();

  DomainResponse.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenantId'] ?? "";
    tenantName = json['tenantName'] ?? "";
    baseDomain = json['baseDomain'];
    apiGatewayUrl = json['apiGatewayUrl'];
    coreServiceUrl = json['coreServiceUrl'];
    apiKeycloakUrl = json['apiKeycloakUrl'];
    apiKeycloakRealm = json['apiKeycloakRealm'];
  }

Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tenantId'] = tenantId;
    data['tenantName'] = tenantName;
    data['baseDomain'] = baseDomain;
    data['apiGatewayUrl'] = apiGatewayUrl;
    data['coreServiceUrl'] = coreServiceUrl;
    data['apiKeycloakUrl'] = apiKeycloakUrl;
    data['apiKeycloakRealm'] = apiKeycloakRealm;
    return data;
  }
}