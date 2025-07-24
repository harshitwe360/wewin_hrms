part of 'punch_in_out_cubit.dart';

abstract class PunchInOutState extends Equatable {
  const PunchInOutState();
}

class PInOutInitState extends PunchInOutState {
  @override
  List<Object?> get props => [];
}

class PInOutLoadingState extends PunchInOutState {
  @override
  List<Object?> get props => [];
}

class PInOutLoadedState extends PunchInOutState {
  final double totalWorkedSeconds;
  const PInOutLoadedState({this.totalWorkedSeconds = 0.0});

  @override
  List<Object> get props => [totalWorkedSeconds];
}

class PInOutErrorState extends PunchInOutState {
  final String message;

  const PInOutErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class PInOutUnAuthState extends PunchInOutState {
  final String message;

  const PInOutUnAuthState({required this.message});

  @override
  List<Object> get props => [message];
}
