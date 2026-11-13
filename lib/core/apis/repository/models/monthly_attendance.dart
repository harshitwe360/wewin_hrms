import '../../../utils/server_time.dart';

/// How a calendar day is shown.
enum DayStatus { present, absent, weekOff, leave, holiday, upcoming, noData }

/// WinHRMS `MonthlyAttendanceResponse` (`GET /api/dashboard/monthly-attendance`).
class MonthlyAttendance {
  const MonthlyAttendance({
    required this.userId,
    required this.userName,
    required this.month,
    required this.year,
    required this.days,
    this.employeeId = "",
    this.processName,
    this.presentDays = 0,
    this.totalHoursWorked = 0,
  });

  final int userId;
  final String userName;
  final String employeeId;
  final String? processName;
  final int presentDays;
  final int month;
  final int year;
  final double totalHoursWorked;
  final List<AttendanceDay> days;

  factory MonthlyAttendance.fromJson(Map<String, dynamic> json) =>
      MonthlyAttendance(
        userId: (json["user_id"] as num?)?.toInt() ?? 0,
        userName: json["user_name"]?.toString() ?? "",
        employeeId: json["employee_id"]?.toString() ?? "",
        processName: json["process_name"]?.toString(),
        presentDays: (json["present_days"] as num?)?.toInt() ?? 0,
        month: (json["month"] as num?)?.toInt() ?? 0,
        year: (json["year"] as num?)?.toInt() ?? 0,
        totalHoursWorked: (json["total_hours_worked"] as num?)?.toDouble() ?? 0,
        days: (json["days"] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(AttendanceDay.fromJson)
            .where((d) => d.date != null)
            .toList(),
      );
}

/// WinHRMS `MonthlyAttendanceDay`.
class AttendanceDay {
  const AttendanceDay({
    required this.date,
    this.punchInAt,
    this.punchOutAt,
    this.totalHours,
    this.breakSeconds,
    this.onLeave = false,
    this.isLwp = false,
    this.leaveStatus,
    this.leaveDurationType,
    this.shiftLabel,
    this.shiftTimeLabel,
    this.isWeekOff = false,
  });

  /// Calendar date (local midnight).
  final DateTime? date;
  final DateTime? punchInAt;
  final DateTime? punchOutAt;
  final double? totalHours;
  final int? breakSeconds;
  final bool onLeave;
  final bool isLwp;
  final String? leaveStatus;
  final String? leaveDurationType;
  final String? shiftLabel;
  final String? shiftTimeLabel;
  final bool isWeekOff;

  bool get hasPunch => punchInAt != null;

  /// [holiday] is a holiday name for this date, if any.
  DayStatus status({required DateTime today, String? holiday}) {
    final DateTime d = date!;
    final DateTime t = DateTime(today.year, today.month, today.day);
    if (hasPunch) return DayStatus.present;
    if (onLeave && leaveStatus != "rejected") return DayStatus.leave;
    if (holiday != null) return DayStatus.holiday;
    if (isWeekOff) return DayStatus.weekOff;
    if (d.isAfter(t)) return DayStatus.upcoming;
    // Today without a punch isn't "absent" yet.
    if (d.isAtSameMomentAs(t)) return DayStatus.noData;
    return DayStatus.absent;
  }

  factory AttendanceDay.fromJson(Map<String, dynamic> json) => AttendanceDay(
        date: ServerTime.parseDate(json["date"]),
        punchInAt: ServerTime.parse(json["punch_in_at"]),
        punchOutAt: ServerTime.parse(json["punch_out_at"]),
        totalHours: (json["total_hours"] as num?)?.toDouble(),
        breakSeconds: (json["break_seconds"] as num?)?.toInt(),
        onLeave: json["on_leave"] == true,
        isLwp: json["is_lwp"] == true,
        leaveStatus: json["leave_status"]?.toString(),
        leaveDurationType: json["leave_duration_type"]?.toString(),
        shiftLabel: json["shift_label"]?.toString(),
        shiftTimeLabel: json["shift_time_label"]?.toString(),
        isWeekOff: json["is_week_off"] == true,
      );
}

/// WinHRMS holiday (`GET /api/holidays`).
class Holiday {
  const Holiday({required this.date, required this.name, this.isOptional = false});

  final DateTime date;
  final String name;
  final bool isOptional;

  static List<Holiday> listFromJson(Map<String, dynamic> json) =>
      (json["items"] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((h) {
            final DateTime? d = ServerTime.parseDate(h["holiday_date"]);
            if (d == null) return null;
            return Holiday(
              date: d,
              name: h["name"]?.toString() ?? "Holiday",
              isOptional: h["is_optional"] == true,
            );
          })
          .whereType<Holiday>()
          .toList();
}
