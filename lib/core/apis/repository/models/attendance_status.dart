import '../../../utils/server_time.dart';

/// WinHRMS `AttendanceStatusResponse` — the signed-in user's current
/// IST-day attendance row (`GET /api/attendance/today`, and `record` in
/// every punch/break response).
class AttendanceStatus {
  const AttendanceStatus({
    required this.attendanceDate,
    this.isPunchedIn = false,
    this.isPunchedOut = false,
    this.isOnBreak = false,
    this.punchInAt,
    this.punchOutAt,
    this.breakStartedAt,
    this.breakSeconds = 0,
    this.totalHours,
    this.elapsedSeconds = 0,
    this.serverTime,
  });

  final String attendanceDate;
  final bool isPunchedIn;
  final bool isPunchedOut;
  final bool isOnBreak;
  final DateTime? punchInAt;
  final DateTime? punchOutAt;
  final DateTime? breakStartedAt;
  final int breakSeconds;
  final double? totalHours;
  final int elapsedSeconds;
  final DateTime? serverTime;

  /// Punched in today and not yet punched out.
  bool get isWorking => isPunchedIn && !isPunchedOut;

  factory AttendanceStatus.fromJson(Map<String, dynamic> json) =>
      AttendanceStatus(
        attendanceDate: json["attendance_date"]?.toString() ?? "",
        isPunchedIn: json["is_punched_in"] ?? false,
        isPunchedOut: json["is_punched_out"] ?? false,
        isOnBreak: json["is_on_break"] ?? false,
        punchInAt: _date(json["punch_in_at"]),
        punchOutAt: _date(json["punch_out_at"]),
        breakStartedAt: _date(json["break_started_at"]),
        breakSeconds: (json["break_seconds"] as num?)?.toInt() ?? 0,
        totalHours: (json["total_hours"] as num?)?.toDouble(),
        elapsedSeconds: (json["elapsed_seconds"] as num?)?.toInt() ?? 0,
        serverTime: _date(json["server_time"]),
      );

  /// Naive timestamps are IST (see [ServerTime]).
  static DateTime? _date(dynamic v) => ServerTime.parse(v);
}
