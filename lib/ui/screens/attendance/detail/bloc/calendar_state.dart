part of 'calendar_cubit.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
}

class CalendarLoadingState extends CalendarState {
  @override
  List<Object> get props => [];
}

class CalendarLoadedState extends CalendarState {
  const CalendarLoadedState({
    required this.month,
    required this.attendance,
    this.holidays = const {},
    this.corrections = const {},
    this.isOwn = true,
  });

  /// First day of the loaded month.
  final DateTime month;
  final MonthlyAttendance attendance;

  /// Keyed by `yyyy-MM-dd`.
  final Map<String, Holiday> holidays;

  /// Latest correction request per `yyyy-MM-dd`.
  final Map<String, AttendanceCorrection> corrections;

  /// Viewing the signed-in user's own attendance (corrections allowed).
  final bool isOwn;

  AttendanceDay? dayFor(DateTime date) {
    for (final d in attendance.days) {
      if (d.date != null &&
          d.date!.year == date.year &&
          d.date!.month == date.month &&
          d.date!.day == date.day) {
        return d;
      }
    }
    return null;
  }

  Holiday? holidayFor(DateTime date) => holidays[ServerTime.dateKey(date)];

  AttendanceCorrection? correctionFor(DateTime date) =>
      corrections[ServerTime.dateKey(date)];

  DayStatus statusFor(DateTime date, {DateTime? today}) {
    final AttendanceDay? d = dayFor(date);
    final DateTime now = today ?? DateTime.now();
    final Holiday? h = holidayFor(date);
    if (d == null) {
      if (h != null) return DayStatus.holiday;
      final DateTime t = DateTime(now.year, now.month, now.day);
      return DateTime(date.year, date.month, date.day).isAfter(t)
          ? DayStatus.upcoming
          : DayStatus.noData;
    }
    return d.status(today: now, holiday: h?.name);
  }

  /// Day counts for the summary row.
  Map<DayStatus, int> counts({DateTime? today}) {
    final Map<DayStatus, int> c = {};
    for (final d in attendance.days) {
      final s = statusFor(d.date!, today: today);
      c[s] = (c[s] ?? 0) + 1;
    }
    return c;
  }

  CalendarLoadedState copyWith(
          {Map<String, AttendanceCorrection>? corrections}) =>
      CalendarLoadedState(
        month: month,
        attendance: attendance,
        holidays: holidays,
        corrections: corrections ?? this.corrections,
        isOwn: isOwn,
      );

  @override
  List<Object> get props => [month, attendance, holidays, corrections, isOwn];
}

class CalendarErrorState extends CalendarState {
  final String message;

  const CalendarErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class CalendarUnAuthState extends CalendarState {
  final String message;

  const CalendarUnAuthState({required this.message});

  @override
  List<Object> get props => [message];
}
