part of 'calendar_cubit.dart';

abstract class CalendarState extends Equatable {
  const CalendarState();
}

class CalendarLoadingState extends CalendarState {
  @override
  List<Object> get props => [];
}

class CalendarLoadedState extends CalendarState {
  final dynamic userAttendance;
  const CalendarLoadedState({required this.userAttendance}); // TodoLoaded({required this.data});

  @override
  List<Object> get props => [userAttendance];
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