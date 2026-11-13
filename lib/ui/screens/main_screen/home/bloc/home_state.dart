part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  /// Today's WinHRMS attendance row; null if it could not be loaded.
  final AttendanceStatus? today;

  /// When [today] was received, used to tick the timer locally.
  final DateTime? loadedAt;

  /// Server message from the last punch/break action, shown once.
  final String? actionMessage;

  const HomeLoadedState({
    this.today,
    this.loadedAt,
    this.actionMessage,
  });

  /// Seconds worked so far, ticking while punched in and not on break.
  int workedSecondsAt(DateTime now) {
    final AttendanceStatus? t = today;
    if (t == null) return 0;
    if (!t.isWorking || t.isOnBreak || loadedAt == null) {
      return t.elapsedSeconds;
    }
    return t.elapsedSeconds + now.difference(loadedAt!).inSeconds;
  }

  @override
  List<Object?> get props => [today, loadedAt, actionMessage];
}

/// Transient: the UI should open the face capture screen for [action]
/// ("in" / "out"). The bloc re-emits the last loaded state right after.
class HomeBiometricRequiredState extends HomeState {
  final String action;

  const HomeBiometricRequiredState({required this.action});

  @override
  List<Object> get props => [action];
}

class HomeErrorState extends HomeState {
  final String message;

  const HomeErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class HomeUnAuthState extends HomeState {
  final String message;

  const HomeUnAuthState({required this.message});

  @override
  List<Object> get props => [message];
}
