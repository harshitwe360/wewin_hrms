import 'dart:convert';
import 'package:flutter/cupertino.dart';

import '../../../core/utils/extension.dart';
import '../../resources/constants.dart';
import '../../services/rest_api/api_base_helper.dart';
import 'models/auth_response.dart';
import 'models/xtnd_models.dart';

abstract class RestApiRepository {
  Future<dynamic> getPunchedLogs({required Map<String, dynamic> variables});

  Future<dynamic> getAttendanceList({required Map<String, dynamic> variables});

  Future<dynamic> getAttendanceUserList(
      {required Map<String, dynamic> variables});

  Future<dynamic> getAdminDashCountData({Map<String, dynamic>? variables});

  Future<dynamic> getAttnTrendData({Map<String, dynamic>? variables});

  Future<dynamic> getUserDetails({Map<String, dynamic>? variables});

  Future<dynamic> submitUserResign({Map<String, dynamic>? variables});

  Future<dynamic> submitAttendCorrection({Map<String, dynamic>? variables});
}

class RestApiRepositoryImp extends RestApiRepository {
  static RestApiRepositoryImp? _instance;

  RestApiRepositoryImp._();

  factory RestApiRepositoryImp() => _instance ??= RestApiRepositoryImp._();

  final ApiBaseHelper _restService = ApiBaseHelper();
  /// `UnauthorisedException().toString()`; blocs compare against this.
  static const String errorStr = AppConstants.unAuthorization;

  @override
  Future getPunchedLogs({required Map<String, dynamic> variables}) async {
    try {

      final result = await _restService.request(
          url: "${AppConstants.reportsUrl}EmployeeAttendance/GetAttendanceDetailsByDate",
          method: MethodType.post,
          checkAuth: true,
          paramsString: json.encode(variables),
      );

      ApiResponse response = apiResponseFromJson(result);
      if (response.status) {
        debugPrint("${response.data}");
        final List<PunchLogs> punchLogs = [];
        if (response.data != null && response.data.isNotEmpty) {
          punchLogs.addAll(punchLogsFromObj(response.data as List<dynamic>));
        }
        response = response.copyWith(data: punchLogs);
        return Future(() => response);
      }

      return Future.error(response.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future getUserDetails({Map<String, dynamic>? variables}) async {
    try {
      final response = await _restService.request(
        url: "${AppConstants.operationalUrl}HRMSAccounts/getUserDetails",
        method: MethodType.post,
        checkAuth: true,
        paramsString: json.encode(variables),
      );

      ApiResponse result = apiResponseFromJson(response);
      if (result.data != null && result.data.isNotEmpty) {
        final User user = userRespFromObject(result.data);
        return Future(() => user);
      }
      return Future.error(result.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future submitUserResign({Map<String, dynamic>? variables}) async {
    try {
      // print(variables);
      final response = await _restService.request(
        url: "${AppConstants.operationalUrl}HRMSAccounts/EmployeeResign",
        method: MethodType.post,
        checkAuth: true,
        paramsString: json.encode(variables),
      );

      ApiResponse result = apiResponseFromJson(response);
      if (result.status) {
        return Future(() => true);
      }
      return Future.error(result.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future submitAttendCorrection({Map<String, dynamic>? variables}) async {
    try {
      // print(variables);
      final response = await _restService.request(
        url: "${AppConstants.operationalUrl}HRMSAccounts/SaveCorrection",
        method: MethodType.post,
        checkAuth: true,
        paramsString: json.encode(variables),
      );

      ApiResponse result = apiResponseFromJson(response);
      if (result.status) {
        return Future(() => true);
      }
      return Future.error(result.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future getAttendanceList({required Map<String, dynamic> variables}) async {
    try {
      final result = await _restService.request(
        url: "${AppConstants.operationalUrl}EmployeeAttendance/GetAttendanceDataByUserId",
        method: MethodType.post,
        checkAuth: true,
        paramsString: json.encode(variables),
      );

      debugPrint("response = $result");
      ApiResponse response = apiResponseFromJson(result);

      if (response.status) {
        debugPrint("${response.data}");
        final List<PunchLogs> attendList = punchLogsFromObj(response.data);
        final List<DateTime> presentList = [];
        final List<DateTime> absentList = [];
        final List<DateTime> weekEndList = [];
        double punchDuration = 0;
        for (PunchLogs item in attendList) {
          // punchDuration += item.workingTime;
          if (item.attendDate != null && item.attendanceStatus == "Present") {
            presentList.add(item.attendDate!);
          } else if (item.attendanceStatus == "weekend") {
            weekEndList.add(item.attendDate!);
          } else if (item.attendanceStatus == "Absent") {
            absentList.add(item.attendDate!);
          }
        }
        // print("attendList $attendList");
        final UserAttendance userAttend = UserAttendance(
            name: "",
            workingTime: punchDuration,
            present: presentList.length,
            presentDay: presentList,
            absent: absentList.length,
            absentDay: absentList,
            weekend: weekEndList.length,
            weekendDay: weekEndList);

        return Future(() => userAttend);
      }
      return Future.error(response.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

/*
  @override
  Future<double> setPunchedOut({Map<String, dynamic>? variables}) async {
    try {

      final response = await _restService.request(
          // baseUrlType: domain.apiGatewayUrl,
          url: "${AppConstants.operationalUrl}me/punch_out/",
          method: MethodType.post,
          checkAuth: true,
          paramsString: json.encode(variables),
          onlyBodyResponse: false
      );

      // print("x-total-worked-seconds = ${response.headers["x-total-worked-seconds"]}");
      Map<String, dynamic> resultMap = json.decode(response.body.toString());
      if (resultMap["success"] != null && resultMap["success"] == true) {
        return Future(() => double.tryParse(response.headers["x-total-worked-seconds"].toString()) ?? 0);
        // return Future(() => true);
      }
      return Future.error("Unable to punch-out.!");
    } on Exception catch (e) {
      return Future.error(e);
    }
  }
*/

  @override
  Future getAttendanceUserList(
      {required Map<String, dynamic> variables}) async {
    try {
      debugPrint("variables = $variables");

      final result = await _restService.request(
          // baseUrlType: domain.apiGatewayUrl,
          url: "${AppConstants.reportsUrl}attendance/datewise_attendance",
          method: MethodType.post,
          checkAuth: true,
          // header: {'Authorization': 'Bearer $token'},
          paramsString: json.encode(variables));

      debugPrint("response = $result");
      ApiResponse response = apiResponseFromJson(result);

      if (response.status) {
        final List<TeamAttendanceUserItem> list =
            teamAttendUserListFromObj(response.data);
        response = response.copyWith(data: list);
        // print("response = ${apiResponseToJson(response)}");
        return Future(() => response);
      }

      return Future.error(response.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future getAdminDashCountData({Map<String, dynamic>? variables}) async {
    try {
      final result = await _restService.request(
          // baseUrlType: domain.apiGatewayUrl,
          url: "${AppConstants.reportsUrl}attendance/summary",
          method: MethodType.post,
          checkAuth: true,
          paramsString: json.encode(variables));

      final resultLateArrival = await _restService.request(
          // baseUrlType: domain.apiGatewayUrl,
          url: "${AppConstants.reportsUrl}attendance/late_arrival",
          method: MethodType.post,
          checkAuth: true,
          paramsString: json.encode(variables));

      final resultBreak = await _restService.request(
          // baseUrlType: domain.apiGatewayUrl,
          url: "${AppConstants.reportsUrl}attendance/break_trends",
          method: MethodType.post,
          checkAuth: true,
          paramsString: json.encode(variables));

      debugPrint("result = $result");
      debugPrint("resultLateArrival = $resultLateArrival");
      debugPrint("resultBreak = $resultBreak");
      ApiResponse response = apiResponseFromJson(result);
      DashCountData dashCount = DashCountData();
      if (response.status) {
        final List<DashAttendance> daList =
            dashAttendListFromObj(response.data);
        for (DashAttendance e in daList) {
          debugPrint("total = ${e.total}");
          if (e.date.isSameDate(DateTime.tryParse(variables?["start_date"]))) {
            dashCount = dashCount.copyWith(
                yesterdayPresent: e.present,
                yesterdayPresentPercent:
                    double.parse(e.presentPercent.toStringAsFixed(2)),
                yesterdayAvgWorkingTime: e.averageWrkTime);
          }
          if (e.date.isSameDate(DateTime.tryParse(variables?["end_date"]))) {
            dashCount = dashCount.copyWith(
                todayPresent: e.present,
                todayPresentPercent:
                    double.parse(e.presentPercent.toStringAsFixed(2)),
                totalUsers: e.total,
                todayAvgWorkingTime: e.averageWrkTime);
          }
        }
      }

      ApiResponse lAResponse = apiResponseFromJson(resultLateArrival);
      if (lAResponse.status) {
        final List<LateArrival> daList =
            lateArrivalListFromObj(lAResponse.data);
        for (LateArrival la in daList) {
          final int tCount = la.earlyCount + la.lateCount + la.onTime;
          if (la.date.isSameDate(DateTime.tryParse(variables?["start_date"]))) {
            dashCount = dashCount.copyWith(
                yesterdayAverageArrivalTime: "$tCount");
          }
          if (la.date.isSameDate(DateTime.tryParse(variables?["end_date"]))) {
            // dashCount = dashCount.copyWith(
            //     todayLateArrivalCount: "$tCount",
            //     todayLateArrivalPercent: (la.lateCount / tCount).isNaN
            //         ? "0"
            //         : ((la.lateCount / tCount) * 100).toStringAsFixed(2));
          }
        }
      }

      ApiResponse bResponse = apiResponseFromJson(resultBreak);
      if (bResponse.status) {
        final List<BreakTime> daList = breakListFromObj(bResponse.data);
        for (BreakTime bt in daList) {
          if (bt.date.isSameDate(DateTime.tryParse(variables?["start_date"]))) {
            dashCount = dashCount.copyWith(
                yesterdayAverageDepartureTime: bt.breakDuration.toString());
          }
          if (bt.date.isSameDate(DateTime.tryParse(variables?["end_date"]))) {
            dashCount = dashCount.copyWith(
                todayAverageDepartureTime: bt.breakDuration.toString());
          }
        }
      }

      response = response.copyWith(data: dashCount);
      return Future(() => response);

      // return Future.error(response.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }

  @override
  Future getAttnTrendData({Map<String, dynamic>? variables}) async {
    try {
      final result = await _restService.request(
          // baseUrlType: domain.apiGatewayUrl,
          url: "${AppConstants.reportsUrl}attendance/summary",
          method: MethodType.post,
          checkAuth: true,
          paramsString: json.encode(variables));

      debugPrint("result = $result");
      ApiResponse response = apiResponseFromJson(result);

      if (response.status) {
        response =
            response.copyWith(data: dashAttendListFromObj(response.data));
        return Future(() => response);
      }

      return Future.error(response.message);
    } on Exception catch (e) {
      return Future.error(e);
    }
  }
}
