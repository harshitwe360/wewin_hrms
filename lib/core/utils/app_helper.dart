import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../config/r.dart';

enum SnackBarMode { error, success }

enum BeforeLate { before, late, onTime }

class AppHelper {
  static AppHelper? _instance;

  AppHelper._();

  factory AppHelper() => _instance ??= AppHelper._();

  static T? enumFromString<T>(Iterable<T> values, String value) {
    return values
        .firstWhere((type) => type.toString().split(".").last == value);
  }

  static double getPercent({required int value, required int total}) =>
      ((value / total) * 100).isNaN
          ? 0.0
          : double.parse(((value / total) * 100).toStringAsFixed(2));

  static double getPercentD({required double value, required double total}) =>
      ((value / total) * 100).isNaN
          ? 0.0
          : double.parse(((value / total) * 100).toStringAsFixed(2));

  static double getWidthPageSize(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static int getInt(String value) => (double.tryParse(value) ?? 0).toInt();

  static double getHeightPageSize(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static int getOffset(int pageNo) =>
      pageNo > 1 ? (pageNo - 1) * AppConstants.perPage : 0;

  static String getAvatarString(String name) {
    // .map((e) => e[0]).toList().join().;
    final List<String> nameSplit = name.trim()
        .replaceAll(RegExp(' +'), ' ').split(" ").map((e) => e[0].toUpperCase()).toList();
    return "${nameSplit.first}${nameSplit.last}";
  }


  static String getLabelFilter(DateTime start, DateTime end) {
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return dateFormat(date: start, format: "d MMM");
    }

    return "${AppHelper.dateFormat(date: start, format: "d MMM")} - ${AppHelper.dateFormat(date: end, format: "d MMM")}";
  }

  static BeforeLate isBeforeOrLate(
      {String? punchIn, String? shiftTime, int? gracePeriod = 0}) {
    if (punchIn != null && shiftTime != null) {
      final DateTime shiftDateTime = DateTime.parse(
          "${dateFormat(dateStr: punchIn)} $shiftTime");
      final DateTime compPunchIn = shiftDateTime.add(Duration(minutes: gracePeriod ?? 0));
      final DateTime userPunchIn = DateTime.parse(punchIn).toLocal();

      final startDiff = userPunchIn.difference(shiftDateTime).inMinutes;
      final endDiff = userPunchIn.difference(compPunchIn).inMinutes;

      if(endDiff > 0){
        return BeforeLate.late;
      } else if(startDiff < 0){
        return BeforeLate.before;
      }

      return BeforeLate.onTime;
    }
    return BeforeLate.onTime;
  }

  static String dateFormat(
      {String? dateStr,
      String? format = "yyyy-MM-dd",
      int? endDays,
      DateTime? date}) {
    var parseDate = DateTime.now();
    if (date != null) {
      parseDate = date;
    }
    if (endDays != null) {
      parseDate = parseDate.subtract(Duration(days: endDays));
    }
    try {
      if (dateStr != null) {
        final df = DateFormat(format, "en");
        parseDate = df.parse(dateStr).toLocal();
      }
      // debugPrint(DateFormat(format).format(parseDate));
      return DateFormat(format).format(parseDate);
    } catch (e) {
      debugPrint("$e");
      if (dateStr != null) {
        final df = DateFormat(format, "en");
        parseDate = df.parse(dateStr).toLocal();
      }
      return DateFormat(format, "en").format(parseDate);
    }
  }

  static DateTime stringToDateTime({String? date,
    String? format = "yyyy-MM-dd"}) {
    var nowDate = DateTime.now();
    try {
      if (date != null) {
        if (format != null) {
          final df = DateFormat(format, "en");
          nowDate = df.parse(date).toLocal();
        } else {
          nowDate = DateTime.parse(date);
        }
      }
    } catch (e){
      debugPrint("$e");
    }
    return nowDate;
  }

  static String firstDayOfMonth(
      {DateTime? date, String? dateStr, String? format = "yyyy-MM-dd"}) {
    var nowDate = DateTime.now();
    if (date != null) {
      nowDate = date;
    }
    if(dateStr !=null){
      nowDate = stringToDateTime(date: dateStr);
    }
    try {
      DateTime firstDate = DateTime(nowDate.year, nowDate.month, 1);
      return DateFormat(format).format(firstDate);
    } catch (e) {
      return DateFormat(format).format(nowDate);
    }
  }

  static String lastDayOfMonth(
      {DateTime? date, String? dateStr, String? format = "yyyy-MM-dd"}) {
    var nowDate = DateTime.now();
    if (date != null) {
      nowDate = date;
    }
    if(dateStr !=null){
      nowDate = stringToDateTime(date: dateStr);
    }
    try {
      DateTime lastDate = (nowDate.month < 12)
          ? DateTime(nowDate.year, nowDate.month + 1, 0)
          : DateTime(nowDate.year + 1, 1, 0);
      return DateFormat(format).format(lastDate);
    } catch (e) {
      return DateFormat(format).format(nowDate);
    }
  }

  static String last7Days(
      {DateTime? date, String? format = "yyyy-MM-dd"}) {
    var nowDate = DateTime.now();
    if (date != null) {
      nowDate = date;
    }
    try {
      DateTime lastDate = nowDate.subtract(const Duration(days: 6));
      return DateFormat(format).format(lastDate);
    } catch (e) {
      return DateFormat(format).format(nowDate);
    }
  }

  static String lastDays(
      {int? days, DateTime? date, String? format = "yyyy-MM-dd"}) {
    var nowDate = DateTime.now();
    if (date != null) {
      nowDate = date;
    }
    try {
      DateTime lastDate = nowDate.subtract(Duration(days: days ?? 1));
      return DateFormat(format).format(lastDate);
    } catch (e) {
      return DateFormat(format).format(nowDate);
    }
  }

  static double timeToSeconds({String? time}) {
    // Split the time into hours, minutes, and seconds
    print("Time : $time");
    List<String> parts = (time ?? "00:00:00").split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    // Convert time to total seconds
    return ((hours * 3600) + (minutes * 60) + seconds).toDouble();
  }

  static String secondsToTime({double second = 0}) {
    // Calculate hours, minutes, and seconds
    int hours = second.toInt() ~/ 3600;
    int minutes = (second.toInt() % 3600) ~/ 60;
    int seconds = second.toInt() % 60;

    // Format time as HH:mm:ss
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  static String timeToAMPM({String time = "00:00:00"}) {
    final d = DateTime.parse("2000-01-01 $time");
    return DateFormat("h:mm a").format(d);
  }

  static String dateTimeToAMPM({DateTime? sDate, String? dateStr, String? returnStr, bool isUtcStr = false}) {
    // print("dateTimeToAMPM = $dateStr");
    if(sDate!=null){
      if(isUtcStr){
        return DateFormat("h:mm a").format(sDate.toLocal());
      }
      return DateFormat("h:mm a").format(sDate);
    } else if (dateStr != null && dateStr.isNotEmpty) {
      if(isUtcStr) {
        dateStr = dateStr.contains("Z") ? dateStr : "${dateStr}Z";
      }
      final date = sDate ?? DateTime.parse(dateStr).toLocal();
      return DateFormat("h:mm a").format(date);
      // return DateFormat("hh:mm a").parse(dateStr).toLocal();
    }
    return returnStr ?? "-- : --";
  }

  static int timeDiff({String? dateStr1, String? dateStr2}) {
    if (dateStr1 != null && dateStr2!=null) {
      final timeStr1 = DateFormat("hh:mm:ss").format(DateTime.parse(dateStr1).toLocal());
      final timeStr2 = DateFormat("hh:mm:ss").format(DateTime.parse(dateStr2).toLocal());
      final date1 = DateTime.parse("2000-01-01 $timeStr1").toLocal();
      final date2 = DateTime.parse("2000-01-01 $timeStr2").toLocal();
      final Duration diff = date1.difference(date2);
      return diff.inMinutes;
    }
    return 00;
  }

  static int dateTimeDiff({String? dateStr1, String? dateStr2}) {
    if (dateStr1 != null && dateStr2!=null) {
      final date1 = DateTime.parse(dateStr1).toLocal();
      final date2 = DateTime.parse(dateStr2).toLocal();
      final Duration diff = date1.difference(date2);
      return diff.inMinutes;
    }
    return 00;
  }

  static String formatInt2({String? string}) {
    if (string != null && string.isNotEmpty) {
      return string.length < 2 ? "0$string" : string;
    }
    return '00';
  }

  static String seconds2min({required int seconds}) {
    debugPrint("seconds = $seconds");
    return formatInt2(string: '${(Duration(seconds: seconds).inMinutes)}');
  }

  /*static String offlineTime({required String punchDuration,
    required String onlineDuration, required String breakDuration}){
    double ob = (double.tryParse(onlineDuration) ?? 0) + (double.tryParse(breakDuration) ?? 0);
    double offTime = (double.tryParse(punchDuration) ?? 0) - ob;

    return stringToTime(offTime>0 ? offTime.toString() : "0");
  }*/

  static String stringToTime(String strValue, {String format = "hm"}) {
    int h, m, s;
    int value = double.tryParse(strValue)?.toInt() ?? 0;
    h = value ~/ 3600;
    m = ((value - h * 3600)) ~/ 60;
    s = value - (h * 3600) - (m * 60);

    String hours = h.toString().length < 2 ? "0$h" : h.toString();
    String minutes = m.toString().length < 2 ? "0$m" : m.toString();
    String secondsLeft = s.toString().length < 2 ? "0$s" : s.toString();
    if (format == "hms") {
      return "${hours}h ${minutes}m ${secondsLeft}s";
    }
    if (format == "ms") {
      return "${minutes}m ${secondsLeft}s";
    }
    if (format == "h") {
      return "${hours}h";
    }
    if (format == "m") {
      return "${minutes}m";
    }
    if (format == ".") {
      return "$hours.$minutes";
    }
    return "${hours.replaceAll("-", "")}h ${minutes.replaceAll("-", "")}m";
  }

  static String durationToTime(String seconds, {String format = "ms"}) {
    int secondsInt = double.tryParse(seconds)?.toInt() ?? 0;
    final duration = Duration(seconds: secondsInt);

    String inTwoDigits(int n) => n.toString().padLeft(2, "0");
    String negativeSign = duration.isNegative ? '-' : '';

    String twoDigitMinutes = inTwoDigits(duration.inMinutes.remainder(60).abs());
    String twoDigitSeconds = inTwoDigits(duration.inSeconds.remainder(60).abs());
    if(format == "hms"){
      return "$negativeSign${inTwoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    if(format == "hm"){
      return "${inTwoDigits(duration.inHours)}h : ${twoDigitMinutes}m";
    }
    return "${twoDigitMinutes}m : ${twoDigitSeconds}s";
  }

  static double timeToDouble(String value) =>
      double.tryParse(stringToTime(value.toString(), format: ".")) ?? 0;

  static int timeToInt(String value) =>
      int.tryParse(stringToTime(value.toString(), format: ".")) ?? 0;

  // static DateTime timeStrToDateTime(String value,
  //     {String? format = "HH:mm:ss"}) =>
  //     DateFormat(format).parse(value.trim()).toLocal();
  static DateTime timeStrToDateTime(String? value, {DateTime? date}) =>
      DateTime.parse("${dateFormat(date: date)} ${(value!=null && value.isNotEmpty ? value : '00:00:00').trim()}")
        .toLocal();

  static Duration parseDuration(String durationStr) {
    List<String> parts = durationStr.split(':');
    int hours = int.tryParse(parts[0]) ?? 00;
    int minutes = int.tryParse(parts[1]) ?? 00;
    int seconds = int.tryParse(parts[2]) ?? 00;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  static List<DateTime> getDaysInBetween(String? startDate, String? endDate) {
    List<DateTime> days = [];
    if(startDate!=null && endDate!=null) {
      final DateTime sDate = DateTime.parse(startDate);
      final DateTime eDate = DateTime.parse(endDate);
      for (int i = 0; i <= eDate.difference(sDate).inDays; i++) {
        days.add(sDate.add(Duration(days: i)));
      }
    }
    return days;
  }

  static bool isTodayOrYesterday(DateTime date) {
    DateTime today = DateTime.now();
    DateTime yesterday = today.subtract(Duration(days: 1));

    // Extract only year, month, and day (ignoring time)
    String formattedDate = "${date.year}-${date.month}-${date.day}";
    String formattedToday = "${today.year}-${today.month}-${today.day}";
    String formattedYesterday = "${yesterday.year}-${yesterday.month}-${yesterday.day}";

    return formattedDate == formattedToday || formattedDate == formattedYesterday;
  }

  static showSnackBar(
    BuildContext context, {
    SnackBarMode? snackBarMode,
    required String content,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        content,
        style: TextStyle(fontSize: 16),
      ),
      backgroundColor: snackBarMode != null
          ? snackBarMode == SnackBarMode.success
              ? const Color(0xFF33D77E)
              : const Color(0xffcf1f60)
          : null,
      behavior: SnackBarBehavior.floating,
      elevation: 0.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ));
  }

/*  static String getGenderValue(Gender selected){
    switch (selected){
      case Gender.M :
        return R.strings.txtGenderM;
      case Gender.F :
        return R.strings.txtGenderF;
      case Gender.O :
        return R.strings.txtGenderO;
      default:
        return R.strings.hintGender;
    }
  }*/

/*static String getInitialRoute() {
    String initialRoute = AppRoutes.login;

    StorageService.instance
        .containsKeyInSecureData(AppConstants.loginDetails)
        .then((isActive) {
      if (isActive) {
        initialRoute = isActive ? AppRoutes.dashboard : AppRoutes.login;
      }
    });

    StorageService.instance
        .containsKeyInSecureData(AppConstants.freshInstall)
        .then((isNotNewUser) {
      if (!isNotNewUser) {
        initialRoute = AppRoutes.launch;
      }
    });

    return initialRoute;
  }*/
/*static String dateDiffHours({String? date}) {
    if (date != null && date.isNotEmpty) {
      try {
        final DateTime date1 = DateTime.parse(date);
        final DateTime date2 = DateTime.now();
        String str = (date2.difference(date1).inHours).toString();
        return str.length < 2 ? "0$str" : str;
        // return date2.difference(date1).inHours.toString();
      } catch (e) {
        return '00';
      }
    }
    return '00';
  }

  static String dateDiffMin({String? date}) {
    if (date != null && date.isNotEmpty) {
      try {
        final DateTime date1 = DateTime.parse(date);
        final DateTime date2 = DateTime.now();
        String str = (date2.difference(date1).inMinutes % 60).toString();
        return str.length < 2 ? "0$str" : str;
        // return (date2.difference(date1).inMinutes % 60).toString();
      } catch (e) {
        return '00';
      }
    }
    return '00';
  }

  static String dateDiffSec({String? date}) {
    if (date != null && date.isNotEmpty) {
      try {
        final DateTime date1 = DateTime.parse(date);
        final DateTime date2 = DateTime.now();
        String str = (date2.difference(date1).inSeconds % 60).toString();
        return str.length < 2 ? "0$str" : str;
      } catch (e) {
        return '00';
      }
    }
    return '00';
  }*/
}
