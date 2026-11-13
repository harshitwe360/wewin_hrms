part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

enum PunchType { btnIn, btnOut }

/// Loads today's status (WinHRMS) and the day's punch logs (legacy).
class DashboardEvent extends HomeEvent {
  final String dateFilter;

  const DashboardEvent({required this.dateFilter});

  @override
  List<Object?> get props => [dateFilter];
}

/// Same as [DashboardEvent]; fired on app resume.
class PunchLogsEvent extends HomeEvent {
  final String dateFilter;

  const PunchLogsEvent({required this.dateFilter});

  @override
  List<Object?> get props => [dateFilter];
}

class PunchInOutEvent extends HomeEvent {
  final PunchType punchType;
  final String todayDate;

  const PunchInOutEvent({required this.todayDate, required this.punchType});

  @override
  List<Object?> get props => [punchType, todayDate];
}

/// Biometric punch finished on the face capture screen.
class PunchCompletedEvent extends HomeEvent {
  final PunchResult result;

  const PunchCompletedEvent({required this.result});

  @override
  List<Object?> get props => [result];
}

class BreakEvent extends HomeEvent {
  final bool start;

  const BreakEvent({required this.start});

  @override
  List<Object?> get props => [start];
}
