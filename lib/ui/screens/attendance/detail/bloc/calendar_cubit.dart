import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/apis/repository/attendance_repo.dart';
import '../../../../../core/apis/repository/models/attendance_correction.dart';
import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/models/monthly_attendance.dart';
import '../../../../../core/config/r.dart';
import '../../../../../core/services/auth/auth_service.dart';
import '../../../../../core/services/rest_api/app_exception.dart';
import '../../../../../core/utils/server_time.dart';

part 'calendar_state.dart';

/// Attendance calendar backed by WinHRMS:
/// `monthly-attendance` (days), `holidays` and `attendance-corrections/me`.
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit({AttendanceRepository? repository})
      : _repo = repository ?? AttendanceRepository(),
        super(CalendarLoadingState());

  final AttendanceRepository _repo;
  final Map<int, Map<String, Holiday>> _holidaysByYear = {};

  /// Guards against an older month's response arriving after a newer one.
  int _request = 0;

  /// Loads [month] (any date inside it). [userId] is only sent when viewing
  /// someone other than the signed-in user.
  Future<void> loadMonth(DateTime month, {String? userId}) async {
    final int request = ++_request;
    emit(CalendarLoadingState());
    try {
      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (auth.user == null || auth.token.isEmpty) {
        await AuthService.instance.clearUserData();
        emit(const CalendarUnAuthState(message: AppConstants.unAuthorization));
        return;
      }
      if (!await NetworkManager().isConnectedToInternet()) {
        emit(CalendarErrorState(message: R.strings.errAPINoNet));
        return;
      }

      final int? otherUser = (userId == null ||
              userId.isEmpty ||
              userId == auth.user!.userId)
          ? null
          : int.tryParse(userId);

      final results = await Future.wait([
        _repo.getMonthlyAttendance(
            month: month.month, year: month.year, userId: otherUser),
        _holidays(month.year),
        // Corrections are the signed-in user's own requests.
        otherUser == null ? _corrections() : Future.value(<String, AttendanceCorrection>{}),
      ]);
      if (request != _request || isClosed) return;

      emit(CalendarLoadedState(
        month: DateTime(month.year, month.month),
        attendance: results[0] as MonthlyAttendance,
        holidays: results[1] as Map<String, Holiday>,
        corrections: results[2] as Map<String, AttendanceCorrection>,
        isOwn: otherUser == null,
      ));
    } on UnauthorisedException {
      if (request == _request && !isClosed) {
        emit(const CalendarUnAuthState(message: AppConstants.unAuthorization));
      }
    } catch (e) {
      if (request == _request && !isClosed) {
        emit(CalendarErrorState(message: e is AppException ? e.message : '$e'));
      }
    }
  }

  /// Re-fetches corrections only (after submitting one).
  Future<void> refreshCorrections() async {
    final CalendarState s = state;
    if (s is! CalendarLoadedState) return;
    try {
      final corrections = await _corrections();
      if (!isClosed) emit(s.copyWith(corrections: corrections));
    } catch (e) {
      debugPrint("refreshCorrections: $e");
    }
  }

  Future<Map<String, Holiday>> _holidays(int year) async {
    final cached = _holidaysByYear[year];
    if (cached != null) return cached;
    try {
      final list = await _repo.getHolidays(year);
      return _holidaysByYear[year] = {
        for (final h in list) ServerTime.dateKey(h.date): h,
      };
    } catch (e) {
      // Holidays are decoration; the calendar still works without them.
      debugPrint("holidays unavailable: $e");
      return const {};
    }
  }

  Future<Map<String, AttendanceCorrection>> _corrections() async {
    try {
      final list = await _repo.getMyCorrections();
      // Latest request per date (the list may hold several).
      final Map<String, AttendanceCorrection> byDate = {};
      for (final c in list) {
        final key = ServerTime.dateKey(c.attendanceDate);
        final existing = byDate[key];
        if (existing == null || c.id > existing.id) byDate[key] = c;
      }
      return byDate;
    } catch (e) {
      debugPrint("corrections unavailable: $e");
      return const {};
    }
  }
}
