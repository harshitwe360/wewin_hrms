import 'dart:convert';

// import 'package:fl_chart/fl_chart.dart';

List<DashCountData> dashboardDataListFromObj(List<dynamic> obj) =>
    List<DashCountData>.from(obj.map((x) => DashCountData.fromJson(x)));

DashCountData dashboardDataFromJson(String str) =>
    DashCountData.fromJson(json.decode(str));

DashCountData dashboardDataFromObj(Map<String, dynamic> obj) =>
    DashCountData.fromJson(obj);

String dashboardDataToJson(DashCountData data) => json.encode(data.toJson());

// Attendance Summery
List<DashAttendance> dashAttendListFromObj(List<dynamic> obj) =>
    List<DashAttendance>.from(obj.map((x) => DashAttendance.fromJson(x)));

String dashAttendListToJson(List<DashAttendance> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Late Arrival Data parse Code
List<LateArrival> lateArrivalListFromObj(List<dynamic> obj) =>
    List<LateArrival>.from(obj.map((x) => LateArrival.fromJson(x)));

String lateArrivalListToJson(List<LateArrival> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Break Time Data parse Code
List<BreakTime> breakListFromObj(List<dynamic> obj) =>
    List<BreakTime>.from(obj.map((x) => BreakTime.fromJson(x)));

String breakListToJson(List<BreakTime> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// Trend Attendance Graph
// List<FlSpot> dashTrendGraphDataFromJson(List<dynamic> json) =>
//     json.isEmpty ? [] : List<FlSpot>.from(
//         json.map((x) => FlSpot(
//             DateTime.parse(x["date"].toString()).day.toDouble(),
//             double.tryParse(x["present"].toString()) ?? 0)));


class DashAttendance {
  final DateTime date;
  final int total;
  final int present;
  final int absent;
  final double averageWrkTime;
  final double presentPercent;
  final double absentPercent;

  DashAttendance({
    required this.date,
    this.total = 0,
    this.present = 0,
    this.absent = 0,
    this.averageWrkTime = 0,
    this.presentPercent = 0,
    this.absentPercent = 0,
  });

  factory DashAttendance.fromJson(Map<String, dynamic> json) => DashAttendance(
        date: DateTime.parse(json["date"]),
        total: json["total"] ?? 0,
        present: json["present"] ?? 0,
        absent: json["absent"] ?? 0,
        averageWrkTime: json["average_wrk_time"]?.toDouble() ?? 0,
        presentPercent: json["present_percent"]?.toDouble() ?? 0,
        absentPercent: json["absent_percent"]?.toDouble() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "date":
            "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
        "total": total,
        "present": present,
        "absent": absent,
        "average_wrk_time": averageWrkTime,
        "present_percent": presentPercent,
        "absent_percent": absentPercent,
      };
}

class LateArrival {
  final DateTime date;
  final int earlyCount;
  final int onTime;
  final int lateCount;
  final int totalUser;

  LateArrival({
    required this.date,
    required this.earlyCount,
    required this.onTime,
    required this.lateCount,
    required this.totalUser,
  });

  LateArrival copyWith({
    DateTime? attendanceDate,
    int? earlyCount,
    int? onTime,
    int? lateCount,
    int? totalUser,
  }) =>
      LateArrival(
        date: attendanceDate ?? date,
        earlyCount: earlyCount ?? this.earlyCount,
        onTime: onTime ?? this.onTime,
        lateCount: lateCount ?? this.lateCount,
        totalUser: totalUser ?? this.totalUser,
      );

  factory LateArrival.fromJson(Map<String, dynamic> json) => LateArrival(
    date: DateTime.parse(json["attendance_date"]),
    earlyCount: json["early_count"] ?? 0,
    onTime: json["on_time"] ?? 0,
    lateCount: json["late_count"] ?? 0,
    totalUser: json["total_user"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "attendance_date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "early_count": earlyCount,
    "on_time": onTime,
    "late_count": lateCount,
    "total_user": totalUser,
  };
}

class BreakTime {
  final DateTime date;
  final double breakDuration;
  final int identityCount;

  BreakTime({
    required this.date,
    required this.breakDuration,
    required this.identityCount,
  });

  BreakTime copyWith({
    DateTime? date,
    double? breakDuration,
    int? identityCount,
  }) => BreakTime(
        date: date ?? this.date,
        breakDuration: breakDuration ?? this.breakDuration,
        identityCount: identityCount ?? this.identityCount,
      );

  factory BreakTime.fromJson(Map<String, dynamic> json) => BreakTime(
    date: DateTime.parse(json["punchInDate"].toString()),
    breakDuration: double.tryParse(json["break_duration"].toString()) ?? 0,
    identityCount: int.tryParse(json["identity_count"].toString()) ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "punchInDate": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "break_duration": breakDuration,
    "identity_count": identityCount,
  };
}

class DashCountData {
  DashCountData({
    this.todayPresentPercent = 0,
    this.yesterdayPresentPercent = 0,
    this.todayPresent = 0,
    this.yesterdayPresent = 0,
    this.totalUsers = 0,
    this.todayLateArrivalPercent = "0",
    this.todayLateArrivalCount = "0",
    this.yesterdayLateArrivalCount = "0",
    this.todayAverageDepartureTime = "0",
    this.yesterdayAverageDepartureTime = "0",
    this.todayAvgWorkingTime = 0,
    this.yesterdayAvgWorkingTime = 0,
  });

  final double todayPresentPercent;
  final double yesterdayPresentPercent;
  final int todayPresent;
  final int yesterdayPresent;
  final int totalUsers;
  final String? todayLateArrivalPercent;
  final String? todayLateArrivalCount;
  final String? yesterdayLateArrivalCount;
  final String? todayAverageDepartureTime;
  final String? yesterdayAverageDepartureTime;
  final double todayAvgWorkingTime;
  final double yesterdayAvgWorkingTime;

  DashCountData copyWith({
    double? todayPresentPercent,
    double? yesterdayPresentPercent,
    int? todayPresent,
    int? yesterdayPresent,
    int? totalUsers,
    String? todayLateArrivalPercent,
    String? todayLateArrivalCount,
    String? yesterdayAverageArrivalTime,
    String? todayAverageDepartureTime,
    String? yesterdayAverageDepartureTime,
    double? todayAvgWorkingTime,
    double? yesterdayAvgWorkingTime,
  }) =>
      DashCountData(
        todayPresentPercent: todayPresentPercent ?? this.todayPresentPercent,
        yesterdayPresentPercent:
            yesterdayPresentPercent ?? this.yesterdayPresentPercent,
        todayPresent: todayPresent ?? this.todayPresent,
        yesterdayPresent: yesterdayPresent ?? this.yesterdayPresent,
        totalUsers: totalUsers ?? this.totalUsers,
        todayLateArrivalPercent: todayLateArrivalPercent ?? this.todayLateArrivalPercent,
        todayLateArrivalCount: todayLateArrivalCount ?? this.todayLateArrivalCount,
        yesterdayLateArrivalCount:
            yesterdayAverageArrivalTime ?? yesterdayLateArrivalCount,
        todayAverageDepartureTime:
            todayAverageDepartureTime ?? this.todayAverageDepartureTime,
        yesterdayAverageDepartureTime:
            yesterdayAverageDepartureTime ?? this.yesterdayAverageDepartureTime,
        todayAvgWorkingTime: todayAvgWorkingTime ?? this.todayAvgWorkingTime,
        yesterdayAvgWorkingTime:
            yesterdayAvgWorkingTime ?? this.yesterdayAvgWorkingTime,
      );

  factory DashCountData.fromJson(Map<String, dynamic> json) => DashCountData(
        todayPresentPercent:
            double.tryParse(json["today_present_percent"].toString()) ?? 0,
        yesterdayPresentPercent:
            double.tryParse(json["yesterday_present_percent"].toString()) ?? 0,
        todayPresent: int.tryParse(json["today_present"].toString()) ?? 0,
        yesterdayPresent:
            int.tryParse(json["yesterday_present"].toString()) ?? 0,
        totalUsers: int.tryParse(json["total_users"].toString()) ?? 0,
        todayLateArrivalPercent: json["today_average_arrival_time"] ?? "0",
        todayLateArrivalCount: json["todayLateArrivalCount"] ?? "0",
        yesterdayLateArrivalCount: json["yesterday_average_arrival_time"] ?? "0",
        todayAverageDepartureTime: json["today_average_departure_time"] ?? "0",
        yesterdayAverageDepartureTime: json["yesterday_average_departure_time"] ?? "0",
        todayAvgWorkingTime:
            double.tryParse(json["today_average_working_hour"].toString()) ?? 0,
        yesterdayAvgWorkingTime: double.tryParse(
                json["yestarday_average_working_hour"].toString()) ??
            0,
      );

  Map<String, dynamic> toJson() => {
        "today_present_percent": todayPresentPercent,
        "yesterday_present_percent": yesterdayPresentPercent,
        "today_present": todayPresent,
        "yesterday_present": yesterdayPresent,
        "total_users": totalUsers,
        "today_average_arrival_time": todayLateArrivalPercent,
        "todayLateArrivalCount": todayLateArrivalCount,
        "yesterday_average_arrival_time": yesterdayLateArrivalCount,
        "today_average_departure_time": todayAverageDepartureTime,
        "yesterday_average_departure_time": yesterdayAverageDepartureTime,
        "today_average_working_hour": todayAvgWorkingTime,
        "yestarday_average_working_hour": yesterdayAvgWorkingTime,
      };
}
