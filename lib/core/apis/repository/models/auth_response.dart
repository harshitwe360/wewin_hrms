import 'dart:convert';

AuthResponse authRespFromJson(String str) =>
    AuthResponse.fromJson(json.decode(str));

AuthResponse authRespFromObject(Map<String, dynamic> json) =>
    AuthResponse.fromJson(json);

User userRespFromJson(String str) => User.fromJson(json.decode(str));

User userRespFromObject(Map<String, dynamic> json) => User.fromJson(json);

String userRespToJson(User data) => json.encode(data.toJson());

String authRespToJson(AuthResponse data) => json.encode(data.toJson());

class AuthResponse {
  AuthResponse({
    this.token = "",
    this.schema = "",
    this.refreshToken = "",
    this.expiresIn = -1,
    this.success = false,
    this.message = "",
    this.user,
  });

  final String token;
  final String schema;
  final String refreshToken;
  /// Minutes, from WinHRMS `Token.expires_in_minutes` (-1 if unknown).
  final int expiresIn;
  final bool success;
  final String message;
  final User? user;

  AuthResponse copyWith({
    String? token,
    String? schema,
    String? refreshToken,
    int? expiresIn,
    bool? success,
    String? message,
    User? user,
  }) =>
      AuthResponse(
        token: token ?? this.token,
        schema: schema ?? this.schema,
        refreshToken: refreshToken ?? this.refreshToken,
        expiresIn: expiresIn ?? this.expiresIn,
        success: success ?? this.success,
        message: message ?? this.message,
        user: user ?? this.user,
      );

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json["access_token"] ??
            (json["data"] is Map ? json["data"]["token"] : null) ??
            "",
        schema: json["schema_name"] ?? "",
        refreshToken: json["refresh_token"] ?? "",
        expiresIn: json["expires_in_minutes"] ?? json["expires_in"] ?? -1,
        message: "${json["detail"] ?? json["message"] ?? ""}",
        success: json["success"] ?? false,
        user: json["data"] == null ? null : User.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "success": success,
        "schema_name": schema,
        "refresh_token": refreshToken,
        "expires_in_minutes": expiresIn,
        "access_token": token,
        "data": user?.toJson()
      };
}

class User {
  final String userId;
  final String? token;
  final String? name;
  final String? photo;
  final String? gender;
  final int? userRoleId;
  final int? companyId;
  final int? locationId;
  final int? branchId;
  final int? processId;
  final String? companyName;
  final String? locationName;
  final String? branchName;
  final String? processName;
  final String? contactNo;
  final String? alternateNo;
  final String? emailId;
  final String? aAdharNumber;
  final String? workEmailId;
  final String role;
  final String? resign;
  final bool? isactive;
  final bool isCorrection;

  // WinHRMS `/api/auth/me` (CurrentUserResponse)
  final String? employeeId;
  final String? status;
  final String? tenantSlug;
  final String? tenantName;
  final bool locationMandatory;
  final bool faceMandatory;
  final List<String> processNames;
  final List<String> pagePermissions;
  final List<String> features;

  bool get isActive => status == null ? (isactive ?? false) : status == "active";

  User({
    this.userId = "0",
    this.token,
    this.name,
    this.photo,
    this.gender,
    this.userRoleId,
    this.companyId,
    this.locationId,
    this.branchId,
    this.processId,
    this.companyName,
    this.locationName,
    this.branchName,
    this.processName,
    this.contactNo,
    this.alternateNo,
    this.emailId,
    this.aAdharNumber,
    this.workEmailId,
    this.role = "",
    this.resign,
    this.isactive = false,
    this.isCorrection = false,
    this.employeeId,
    this.status,
    this.tenantSlug,
    this.tenantName,
    this.locationMandatory = false,
    this.faceMandatory = false,
    this.processNames = const [],
    this.pagePermissions = const [],
    this.features = const [],
  });

  /// Maps WinHRMS `GET /api/auth/me` onto the app's User.
  factory User.fromMe(Map<String, dynamic> json) => User(
    userId: (json["id"] ?? "0").toString(),
    employeeId: json["employee_id"]?.toString(),
    name: json["full_name"],
    emailId: json["email"],
    workEmailId: json["email"],
    role: json["role"]?.toString() ?? "",
    status: json["status"]?.toString(),
    isactive: json["status"] == "active",
    photo: json["avatar_url"],
    companyName: json["tenant_name"],
    tenantSlug: json["tenant_slug"],
    tenantName: json["tenant_name"],
    processName: _strList(json["process_names"]).join(", "),
    locationMandatory: json["location_mandatory"] ?? false,
    faceMandatory: json["face_mandatory"] ?? false,
    processNames: _strList(json["process_names"]),
    pagePermissions: _strList(json["page_permissions"]),
    features: _strList(json["features"]),
  );

  static List<String> _strList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory User.fromJson(Map<String, dynamic> json) => User(
    userId: (json["userId"] ?? "0").toString(),
    token: json["token"],
    name: json["name"],
    photo: json["photo"],
    gender: json["gender"],
    userRoleId: json["userRoleId"],
    companyId: json["companyId"],
    locationId: json["locationId"],
    branchId: json["branch_id"],
    processId: json["process_Id"],
    companyName: json["company_name"],
    locationName: json["location_name"],
    branchName: json["branch_name"],
    processName: json["process_name"],
    contactNo: json["contact_No"],
    alternateNo: json["alternate_No"],
    emailId: json["emailId"],
    aAdharNumber: json["aAdharNumber"],
    workEmailId: json["workEmailId"],
    resign: json["resion"],
    role: json["role_name"] ?? "",
    isactive: json["isactive"] ?? false,
    isCorrection: json["isCorrection"] ?? false,
    employeeId: json["employee_id"]?.toString(),
    status: json["status"]?.toString(),
    tenantSlug: json["tenant_slug"],
    tenantName: json["tenant_name"],
    locationMandatory: json["location_mandatory"] ?? false,
    faceMandatory: json["face_mandatory"] ?? false,
    processNames: _strList(json["process_names"]),
    pagePermissions: _strList(json["page_permissions"]),
    features: _strList(json["features"]),
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "token": token,
    "name": name,
    "photo": photo,
    "gender": gender,
    "userRoleId": userRoleId,
    "companyId": companyId,
    "locationId": locationId,
    "branch_id": branchId,
    "process_Id": processId,
    "company_name": companyName,
    "location_name": locationName,
    "branch_name": branchName,
    "process_name": processName,
    "contact_No": contactNo,
    "alternate_No": alternateNo,
    "emailId": emailId,
    "aAdharNumber": aAdharNumber,
    "workEmailId": workEmailId,
    "resion": resign,
    "role_name":role,
    "isactive": isactive,
    "isCorrection": isCorrection,
    "employee_id": employeeId,
    "status": status,
    "tenant_slug": tenantSlug,
    "tenant_name": tenantName,
    "location_mandatory": locationMandatory,
    "face_mandatory": faceMandatory,
    "process_names": processNames,
    "page_permissions": pagePermissions,
    "features": features,
  };
}

class Tenant {
  Tenant({
    this.companyName = "",
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipcode,
    this.isActive = false,
  });

  final String companyName;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipcode;
  final bool isActive;

  factory Tenant.fromJson(Map<String, dynamic> json) => Tenant(
        companyName: json["company_name"] ?? "",
        address: json["address"] ?? "",
        city: json["city"] ?? "",
        state: json["state"] ?? "",
        country: json["country"] ?? "",
        zipcode: json["zipcode"],
        isActive: json["is_active"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "company_name": companyName,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "zipcode": zipcode,
        "is_active": isActive,
      };
}

class CurrentShift {
  CurrentShift({
    this.startTime = "",
    this.endTime = "",
    this.shiftName = "",
    this.gracePeriod = 0,
    this.maximumBreakTime = 0,
    this.workDays = const[]
  });

  final String startTime;
  final String endTime;
  final int gracePeriod;
  final int maximumBreakTime;
  final String shiftName;
  final List<String> workDays;

  factory CurrentShift.fromJson(Map<String, dynamic> json) => CurrentShift(
        shiftName: json["name"] ?? "",
        startTime: json["start_time"] ?? "",
        endTime: json["end_time"] ?? "",
        gracePeriod: json["grace_period"] ?? 0,
        maximumBreakTime: json["maximum_break_time"] ?? 0,
        workDays: List<String>.from(json["work_days"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "name": shiftName,
        "start_time": startTime,
        "end_time": endTime,
        "grace_period": gracePeriod,
        "maximum_break_time": maximumBreakTime,
        "work_days": List<dynamic>.from(workDays.map((x) => x)),
      };
}

class GeofenceSet {
  GeofenceSet({required this.coordinates, this.name = ""});

  final Coordinates coordinates;
  final String name;

  factory GeofenceSet.fromJson(Map<String, dynamic> jsonMap) => GeofenceSet(
        name: jsonMap["name"] ?? "",
        coordinates: jsonMap["cords"] != null
            ? Coordinates.fromJson(json.decode(jsonMap["cords"]))
            : Coordinates(),
      );

  Map<String, dynamic> toJson() =>
      {"cords": json.encode(coordinates.toJson()), "name": name};
}

class Coordinates {
  Coordinates({
    this.lat = 0,
    this.long = 0,
    this.radius = 10,
  });

  final double lat;
  final double long;
  final double radius;

  factory Coordinates.fromJson(Map<String, dynamic> json) => Coordinates(
      lat: double.tryParse(json["lat"].toString()) ?? 0,
      long: double.tryParse(json["long"].toString()) ?? 0,
      radius: double.tryParse(json["radius"].toString()) ?? 10);

  Map<String, dynamic> toJson() => {"lat": lat, "long": long, "radius": radius};
}
