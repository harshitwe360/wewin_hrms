import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../../core/apis/repository/attendance_repo.dart';
import '../../../../../core/apis/repository/models/attendance_status.dart';
import '../../../../../core/apis/repository/models/auth_response.dart';
import '../../../../../core/apis/repository/resp_api_repo.dart';
import '../../../../../core/config/r.dart';
import '../../../../../core/services/auth/auth_service.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../core/services/rest_api/app_exception.dart';
import '../../../../../core/utils/app_helper.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  /// Last good data, restored after an action fails so the UI keeps
  /// showing the real punch state instead of falling back to "Punch In".
  HomeLoadedState _last = const HomeLoadedState();

  HomeBloc() : super(HomeLoadingState()) {
    on<DashboardEvent>((e, emit) => _load(e.dateFilter, emit));
    on<PunchLogsEvent>((e, emit) => _load(e.dateFilter, emit));
    on<PunchInOutEvent>(_punchInOut);
    on<BreakEvent>(_onBreak);
    on<PunchCompletedEvent>(_onPunchCompleted);
  }

  Future<void> _load(String dateFilter, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      if (auth.user == null || auth.token.isEmpty) {
        await AuthService.instance.clearUserData();
        emit(const HomeUnAuthState(message: AppConstants.unAuthorization));
        return;
      }
      if (!await NetworkManager().isConnectedToInternet()) {
        emit(HomeErrorState(message: R.strings.errAPINoNet));
        emit(_last);
        return;
      }

      // Today's row drives both the punch card and the punch log
      // (WinHRMS keeps one attendance row per day).
      final AttendanceStatus today = await _attendanceRepository.getToday();
      _last = HomeLoadedState(today: today, loadedAt: DateTime.now());
      emit(_last);
    } catch (e) {
      _emitFailure(e, emit);
    }
  }

  Future<void> _punchInOut(PunchInOutEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      final User? user = auth.user;
      if (user == null || auth.token.isEmpty) {
        await AuthService.instance.clearUserData();
        emit(const HomeUnAuthState(message: AppConstants.unAuthorization));
        return;
      }
      if (!await NetworkManager().isConnectedToInternet()) {
        emit(HomeErrorState(message: R.strings.errAPINoNet));
        emit(_last);
        return;
      }

      // Face-mandatory users go through the biometric screen, which does the
      // location check, session and capture, then reports back with
      // PunchCompletedEvent.
      if (user.faceMandatory) {
        emit(HomeBiometricRequiredState(
            action: event.punchType == PunchType.btnIn ? "in" : "out"));
        emit(_last);
        return;
      }

      final PunchResult result;
      if (event.punchType == PunchType.btnIn) {
        Position? position;
        if (user.locationMandatory) {
          position = await LocationService.instance.currentPosition();
          final LocationCheck check = await _attendanceRepository.validateLocation(
              latitude: position.latitude, longitude: position.longitude);
          if (!check.ok) {
            emit(HomeErrorState(message: check.message.isNotEmpty
                ? check.message : R.strings.msgNotAllowedPP));
            emit(_last);
            return;
          }
        }
        result = await _attendanceRepository.punchIn(
            latitude: position?.latitude, longitude: position?.longitude);
      } else {
        result = await _attendanceRepository.punchOut();
      }

      await _afterAction(result, auth, event.todayDate, emit);
    } catch (e) {
      _emitFailure(e, emit);
    }
  }

  Future<void> _onBreak(BreakEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      final PunchResult result = event.start
          ? await _attendanceRepository.breakStart()
          : await _attendanceRepository.breakEnd();
      await _afterAction(result, auth, AppHelper.dateFormat(), emit);
    } catch (e) {
      _emitFailure(e, emit);
    }
  }

  Future<void> _onPunchCompleted(
      PunchCompletedEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoadingState());
    try {
      final AuthResponse auth = await AuthService.instance.getCurrentUserData();
      await _afterAction(event.result, auth, AppHelper.dateFormat(), emit);
    } catch (e) {
      _emitFailure(e, emit);
    }
  }

  Future<void> _afterAction(PunchResult result, AuthResponse auth,
      String dateFilter, Emitter<HomeState> emit) async {
    _last = HomeLoadedState(today: result.record, loadedAt: DateTime.now());
    emit(HomeLoadedState(
        today: _last.today,
        loadedAt: _last.loadedAt,
        actionMessage: result.message));
  }

  void _emitFailure(Object e, Emitter<HomeState> emit) {
    if (e is UnauthorisedException ||
        e.toString() == RestApiRepositoryImp.errorStr) {
      emit(HomeUnAuthState(message: e.toString()));
      return;
    }
    emit(HomeErrorState(message: e.toString()));
    emit(_last);
  }
}
