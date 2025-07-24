part of 'home_bloc.dart';

class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeLoadingState extends HomeState {}

class HomeLoadedState extends HomeState {
  final ApiResponse? punchLogs;
  final ApiResponse? punchStatus;
  const HomeLoadedState({this.punchLogs, this.punchStatus}); // TodoLoaded({required this.data});

  @override
  List<Object?> get props => [punchLogs, punchStatus];
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