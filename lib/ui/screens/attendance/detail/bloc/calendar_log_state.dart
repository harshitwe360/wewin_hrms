part of 'calendar_log_cubit.dart';

abstract class CalendarLogState extends Equatable {
  const CalendarLogState();
}

class CalendarLogLoadingState extends CalendarLogState {
  @override
  List<Object> get props => [];
}

class CalendarLogLoadedState extends CalendarLogState {
  final dynamic punchLogs;
  const CalendarLogLoadedState({required this.punchLogs}); // TodoLoaded({required this.data});

  @override
  List<Object> get props => [punchLogs];
}

class CalendarLogErrorState extends CalendarLogState {
  final String message;

  const CalendarLogErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class CalendarLogUnAuthState extends CalendarLogState {
  final String message;

  const CalendarLogUnAuthState({required this.message});

  @override
  List<Object> get props => [message];
}
