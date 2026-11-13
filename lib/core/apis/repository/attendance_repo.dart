import 'dart:convert';

import '../../services/rest_api/api_base_helper.dart';
import '../api_endpoints.dart';
import 'models/attendance_status.dart';
import 'models/attendance_correction.dart';
import 'models/biometric_session.dart';
import 'models/monthly_attendance.dart';
import '../../utils/server_time.dart';

/// WinHRMS attendance API. Errors propagate as AppException subclasses.
class AttendanceRepository {
  static AttendanceRepository? _instance;

  AttendanceRepository._();

  factory AttendanceRepository() => _instance ??= AttendanceRepository._();

  final ApiBaseHelper _restService = ApiBaseHelper();

  Future<AttendanceStatus> getToday() async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.attendanceToday,
      method: MethodType.get,
      checkAuth: true,
    );
    return AttendanceStatus.fromJson(json.decode(body));
  }

  /// Month of daily rows. [userId] only for viewing someone else.
  Future<MonthlyAttendance> getMonthlyAttendance(
      {required int month, required int year, int? userId}) async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.monthlyAttendance,
      method: MethodType.get,
      checkAuth: true,
      params: {
        "month": month,
        "year": year,
        if (userId != null) "user_id": userId,
      },
    );
    return MonthlyAttendance.fromJson(json.decode(body));
  }

  Future<List<Holiday>> getHolidays(int year) async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.holidays,
      method: MethodType.get,
      checkAuth: true,
      params: {"year": year},
    );
    return Holiday.listFromJson(json.decode(body));
  }

  Future<List<AttendanceCorrection>> getMyCorrections() async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.myCorrections,
      method: MethodType.get,
      checkAuth: true,
    );
    return AttendanceCorrection.listFromJson(json.decode(body));
  }

  /// [punchIn] / [punchOut] are "HH:MM" (IST), as the web app sends them.
  /// [reason] must be at least 10 characters.
  Future<AttendanceCorrection?> submitCorrection({
    required DateTime date,
    required CorrectionType type,
    required String reason,
    String? punchIn,
    String? punchOut,
  }) async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.corrections,
      method: MethodType.post,
      checkAuth: true,
      paramsString: json.encode(correctionBody(
          date: date,
          type: type,
          reason: reason,
          punchIn: punchIn,
          punchOut: punchOut)),
    );
    return AttendanceCorrection.fromJson(json.decode(body));
  }

  /// `AttendanceCorrectionCreate` body (same shape the web app sends).
  static Map<String, dynamic> correctionBody({
    required DateTime date,
    required CorrectionType type,
    required String reason,
    String? punchIn,
    String? punchOut,
  }) =>
      {
        "attendance_date": ServerTime.dateKey(date),
        "correction_type": type.apiValue,
        "reason": reason.trim(),
        "requested_punch_in": type.needsIn ? punchIn : null,
        "requested_punch_out": type.needsOut ? punchOut : null,
      };

  /// Geofence pre-check; does not punch.
  Future<LocationCheck> validateLocation(
      {required double latitude, required double longitude}) async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.validateLocation,
      method: MethodType.post,
      checkAuth: true,
      paramsString: json.encode({"latitude": latitude, "longitude": longitude}),
    );
    final Map<String, dynamic> map = json.decode(body);
    return LocationCheck(
        ok: map["ok"] == true, message: map["message"]?.toString() ?? "");
  }

  /// Direct punch-in. Omit coordinates when location is not mandatory.
  Future<PunchResult> punchIn({double? latitude, double? longitude}) =>
      _punch(ApiEndpoints.punchIn, {
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
      });

  Future<PunchResult> punchOut() => _punch(ApiEndpoints.punchOut, {});

  Future<PunchResult> breakStart() => _punch(ApiEndpoints.breakStart, null);

  Future<PunchResult> breakEnd() => _punch(ApiEndpoints.breakEnd, null);

  /// Starts a gate-grade face session. [action] is "in" or "out".
  Future<BiometricSession> startBiometricSession(String action) async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: ApiEndpoints.biometricSessions,
      method: MethodType.post,
      checkAuth: true,
      paramsString: json.encode({"action": action}),
    );
    return BiometricSession.fromJson(json.decode(body),
        receivedAt: DateTime.now());
  }

  /// Completes the session with exactly 3 frames; this performs the punch.
  Future<PunchResult> completeBiometricSession({
    required String sessionUuid,
    required String action,
    required List<BiometricFrame> frames,
    double? latitude,
    double? longitude,
  }) =>
      _punch(ApiEndpoints.biometricSessionComplete(sessionUuid), {
        "action": action,
        if (latitude != null) "latitude": latitude,
        if (longitude != null) "longitude": longitude,
        "frames": frames.map((f) => f.toJson()).toList(),
      });

  Future<PunchResult> _punch(String url, Map<String, dynamic>? payload) async {
    final String body = await _restService.request(
      baseUrlType: ApiEndpoints.baseUrl,
      url: url,
      method: MethodType.post,
      checkAuth: true,
      paramsString: payload == null ? "" : json.encode(payload),
    );
    return PunchResult.fromJson(json.decode(body));
  }
}

class LocationCheck {
  const LocationCheck({required this.ok, required this.message});

  final bool ok;
  final String message;
}

/// WinHRMS `PunchResponse`.
class PunchResult {
  const PunchResult({required this.message, required this.record});

  final String message;
  final AttendanceStatus record;

  factory PunchResult.fromJson(Map<String, dynamic> json) => PunchResult(
        message: json["message"]?.toString() ?? "",
        record: AttendanceStatus.fromJson(json["record"] ?? const {}),
      );
}
