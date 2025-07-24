part of 'att_user_list_bloc.dart';

/*abstract class AttUserListState extends Equatable {
  const AttUserListState();
}*/

class AttUserListState extends Equatable {
  const AttUserListState();

  @override
  List<Object> get props => [];
}

class AULoadingState extends AttUserListState {}

class AULoadedState extends AttUserListState {
  final dynamic attUserList;
  const AULoadedState({required this.attUserList}); // TodoLoaded({required this.data});

  @override
  List<Object> get props => [attUserList];
}

class AUErrorState extends AttUserListState {
  final String message;

  const AUErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class AUUnAuthState extends AttUserListState {
  final String message;

  const AUUnAuthState({required this.message});

  @override
  List<Object> get props => [message];
}