part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
}

enum PunchType { BtnIn, BtnOut }

class DashboardEvent extends HomeEvent {
  final String dateFilter;

  const DashboardEvent({required this.dateFilter});

  @override
  List<Object> get props => [];
}

class PunchLogsEvent extends HomeEvent {
  final String dateFilter;

  const PunchLogsEvent({required this.dateFilter});

  @override
  List<Object> get props => [];
}

class PunchInOutEvent extends HomeEvent {
  final PunchType punchType;
  final String? punchOutId;
  final String todayDate;

  const PunchInOutEvent({
    this.punchOutId,
    required this.todayDate,
    required this.punchType
  });

  @override
  List<Object?> get props => [punchType, punchOutId, todayDate];
}