import '../../../utils/server_time.dart';

/// `AttendanceCorrectionType`.
enum CorrectionType {
  punchIn("punch_in", "Punch in time"),
  punchOut("punch_out", "Punch out time"),
  both("both", "Both punch in & out");

  const CorrectionType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get needsIn => this != CorrectionType.punchOut;
  bool get needsOut => this != CorrectionType.punchIn;
}

/// WinHRMS `AttendanceCorrectionResponse` (only the fields the app uses).
class AttendanceCorrection {
  const AttendanceCorrection({
    required this.id,
    required this.attendanceDate,
    required this.correctionType,
    required this.reason,
    required this.status,
    this.requestedPunchInAt,
    this.requestedPunchOutAt,
    this.reviewNotes,
    this.reviewedByName,
  });

  final int id;
  final DateTime attendanceDate;
  final String correctionType;
  final String reason;

  /// pending | approved | rejected
  final String status;
  final DateTime? requestedPunchInAt;
  final DateTime? requestedPunchOutAt;
  final String? reviewNotes;
  final String? reviewedByName;

  bool get isPending => status == "pending";

  static AttendanceCorrection? fromJson(Map<String, dynamic> json) {
    final DateTime? date = ServerTime.parseDate(json["attendance_date"]);
    if (date == null) return null;
    return AttendanceCorrection(
      id: (json["id"] as num?)?.toInt() ?? 0,
      attendanceDate: date,
      correctionType: json["correction_type"]?.toString() ?? "",
      reason: json["reason"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "pending",
      requestedPunchInAt: ServerTime.parse(json["requested_punch_in_at"]),
      requestedPunchOutAt: ServerTime.parse(json["requested_punch_out_at"]),
      reviewNotes: json["review_notes"]?.toString(),
      reviewedByName: json["reviewed_by_name"]?.toString(),
    );
  }

  static List<AttendanceCorrection> listFromJson(Map<String, dynamic> json) =>
      (json["items"] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .whereType<AttendanceCorrection>()
          .toList();
}
