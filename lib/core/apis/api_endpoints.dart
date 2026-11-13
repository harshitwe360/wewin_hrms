import '../resources/constants.dart';

/// Endpoint paths for the WinHRMS backend (https://winhrms.wewinlimited.com).
///
/// Contract source: live OpenAPI at `${AppConstants.winHrmsServerUrl}/openapi.json`.
/// Pass [ApiEndpoints.baseUrl] as `baseUrlType` to `ApiBaseHelper.request`.
///
/// Legacy endpoints (dashboard, team attendance, calendar, corrections,
/// resign, signup) still live on [AppConstants.coreServerUrl] and are not
/// listed here.
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = AppConstants.winHrmsServerUrl;

  // Auth
  static const String login = "/api/auth/login/json";
  static const String otpRequest = "/api/auth/otp/request";
  static const String otpVerify = "/api/auth/otp/verify";
  static const String me = "/api/auth/me";
  static const String forgotPassword = "/api/auth/forgot-password";
  static const String resetPassword = "/api/auth/reset-password";

  // Attendance
  static const String attendanceToday = "/api/attendance/today";
  static const String validateLocation = "/api/attendance/validate-location";
  static const String punchIn = "/api/attendance/punch-in";
  static const String punchOut = "/api/attendance/punch-out";
  static const String breakStart = "/api/attendance/break/start";
  static const String breakEnd = "/api/attendance/break/end";
  static const String biometricSessions = "/api/attendance/biometric-sessions";

  // Attendance history & corrections
  static const String monthlyAttendance = "/api/dashboard/monthly-attendance";
  static const String holidays = "/api/holidays";
  static const String corrections = "/api/attendance-corrections";
  static const String myCorrections = "/api/attendance-corrections/me";

  static String biometricSessionComplete(String sessionUuid) =>
      "$biometricSessions/${Uri.encodeComponent(sessionUuid)}/complete";
}
