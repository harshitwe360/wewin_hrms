import 'dart:convert';

List<AttendanceItem> attendanceListFromObj(List<dynamic> obj) =>
    List<AttendanceItem>.from(obj.map((x) => AttendanceItem.fromJson(x)));

UserAttendance userAttendanceFromObj(Map<String, dynamic> obj) =>
    UserAttendance.fromJson(obj);

String userAttendanceToJson(UserAttendance data) => json.encode(data.toJson());

class UserAttendance {
  UserAttendance({
    this.workingTime = 0,
    this.goal = 0,
    this.present = 0,
    this.presentDay = const [],
    this.absent = 0,
    this.absentDay = const [],
    this.weekend = 0,
    this.weekendDay = const [],
    this.name = "",
  });

  final double workingTime;
  final double goal;
  final int present;
  final List<DateTime> presentDay;
  final int absent;
  final List<DateTime> absentDay;
  final int weekend;
  final List<DateTime> weekendDay;
  final String name;

  factory UserAttendance.fromJson(Map<String, dynamic> json) => UserAttendance(
        workingTime: double.tryParse(json["working_hour"].toString()) ?? 0,
        goal: json["goal"],
        present: json["present"],
        presentDay: json["presendDay"] == null
            ? []
            : List<DateTime>.from(
                json["presendDay"].map((x) => DateTime.parse(x))),
        absent: json["absent"],
        absentDay: json["absentDay"] == null
            ? []
            : List<DateTime>.from(
                json["absentDay"].map((x) => DateTime.parse(x))),
        weekend: json["weekend"],
        weekendDay: json["weekendDay"] == null
            ? []
            : List<DateTime>.from(
                json["weekendDay"].map((x) => DateTime.parse(x))),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "working_hour": workingTime,
        "goal": goal,
        "present": present,
        "presendDay": List<dynamic>.from(presentDay.map((x) =>
            "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
        "absent": absent,
        "absentDay": List<dynamic>.from(absentDay.map((x) =>
            "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
        "weekend": weekend,
        "weekendDay": List<dynamic>.from(weekendDay.map((x) =>
            "${x.year.toString().padLeft(4, '0')}-${x.month.toString().padLeft(2, '0')}-${x.day.toString().padLeft(2, '0')}")),
        "name": name,
      };
}

class AttendanceItem {
  final int? id;
  final int? userId;
  final DateTime? attndDate;
  final String? inTime;
  final String? arrival;
  final String? outTime;
  final String? departure;
  final String? duration;
  final int? shiftId;
  final AttendanceStatus? attendanceStatus;

  AttendanceItem({
    this.id,
    this.userId,
    this.attndDate,
    this.inTime,
    this.arrival,
    this.outTime,
    this.departure,
    this.duration,
    this.shiftId,
    this.attendanceStatus,
  });

  factory AttendanceItem.fromRawJson(String str) => AttendanceItem.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AttendanceItem.fromJson(Map<String, dynamic> json) => AttendanceItem(
    id: json["id"],
    userId: json["userId"],
    attndDate: json["attndDate"] == null ? null : DateTime.parse(json["attndDate"]),
    inTime: json["in_Time"],
    arrival: json["arrival"],
    outTime: json["out_Time"],
    departure: json["departure"],
    duration: json["duration"],
    shiftId: json["shift_Id"],
    attendanceStatus: attendanceStatusValues.map[json["attendance_Status"]]!,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "attndDate": attndDate?.toIso8601String(),
    "in_Time": inTime,
    "arrival": arrival,
    "out_Time": outTime,
    "departure": departure,
    "duration": duration,
    "shift_Id": shiftId,
    "attendance_Status": attendanceStatusValues.reverse[attendanceStatus],
  };
}

enum AttendanceStatus {
  ABSENT,
  PRESENT,
  WEEKEND
}

final attendanceStatusValues = EnumValues({
  "Absent": AttendanceStatus.ABSENT,
  "Present": AttendanceStatus.PRESENT,
  "weekend": AttendanceStatus.WEEKEND
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}