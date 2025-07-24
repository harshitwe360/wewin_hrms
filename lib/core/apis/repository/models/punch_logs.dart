import 'dart:convert';

List<PunchLogs> punchLogsFromObj(List<dynamic> obj) =>
    List<PunchLogs>.from(obj.map((x) => PunchLogs.fromJson(x)));
    // PunchLogs.fromJson(obj);

PunchLogs punchedStatusFromObj(Map<String, dynamic> obj) => PunchLogs.fromJson(obj);

PunchLogs punchLogsFromJson(String str) => PunchLogs.fromJson(json.decode(str));

String punchLogsToJson(PunchLogs data) => json.encode(data.toJson());

String punchLogsListToJson(List<PunchLogs> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PunchLogs {
  PunchLogs({
    required this.id,
    this.workingTime = "00:00:00",
    this.userId = "",
    this.inTime = "",
    this.outTime = "00:00:00",
    // required this.deviceInfo,
    required this.inLatLong,
    required this.outLatLong,
    this.attendDate,
    this.arrival,
    this.departure,
    this.shiftId,
    this.attendanceStatus,
    this.notes = "",
  });

  final String id;
  final String userId;
  final DateTime? attendDate;
  final String inTime;
  final String? arrival;
  final String outTime;
  final String? departure;
  final String? workingTime;
  final String? shiftId;
  final String? attendanceStatus;
  final String notes;
  // final DeviceInfo deviceInfo;
  final LatLong? inLatLong;
  final LatLong? outLatLong;

  factory PunchLogs.fromJson(Map<String, dynamic> json) => PunchLogs(
    id: json["id"]?.toString() ?? "",
    userId: json["userId"]?.toString() ?? "",
    workingTime: json["duration"]?.toString() ?? "00:00:00",
    inTime: json["in_Time"]?.toString() ?? "00:00:00",
    outTime: json["out_Time"]?.toString() ?? "00:00:00",
    // deviceInfo: json["device_info"] == null ? null : DeviceInfo.fromJson(json["device_info"]),
    inLatLong: json["in_lat_long"] == null
        ? null : LatLong.fromJson(json["in_lat_long"]),
    outLatLong: json["out_lat_long"] == null
        ? null : LatLong.fromJson(json["out_lat_long"]),
    attendDate: json["attndDate"] == null ? null : DateTime.parse(json["attndDate"]),
    arrival: json["arrival"]?.toString() ?? "",
    departure: json["departure"]?.toString() ?? "",
    shiftId: json["shift_Id"]?.toString() ?? "",
    attendanceStatus: json["attendance_Status"]?.toString() ?? "",
    notes: json["notes"]?.toString() ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "duration": workingTime,
    "in_Time": inTime,
    "out_Time": outTime,
    // "device_info": deviceInfo == null ? null : deviceInfo.toJson(),
    "in_lat_long": inLatLong?.toJson(),
    "out_lat_long": outLatLong?.toJson(),
    "attndDate": attendDate?.toIso8601String(),
    "arrival": arrival,
    "departure": departure,
    "shift_Id": shiftId,
    "attendance_Status": attendanceStatus,
    "notes": notes,
  };
}

class LatLong {
  LatLong({
    this.lat = 0,
    this.long = 0,
    this.type = "circle",
    this.radius = 10,
  });

  final double lat;
  final double long;
  final String type;
  final double radius;

  factory LatLong.fromJson(Map<String, dynamic> json) => LatLong(
    lat: json["lat"] == null ? 0 : json["lat"].toDouble(),
    long: json["long"] == null ? 0 : json["long"].toDouble(),
    type: json["type"] ?? "circle",
    radius: json["radius"] == null ? 10 : json["radius"].toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "lat": lat,
    "long": long,
    "type": type,
    "radius": radius,
  };
}

