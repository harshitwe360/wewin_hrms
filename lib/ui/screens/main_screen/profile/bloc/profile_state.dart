part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
}

class ProfileLoading extends ProfileState {
  @override
  List<Object> get props => [];
}

class ProfileLoadedState extends ProfileState {
  final dynamic userDetails;
  const ProfileLoadedState({required this.userDetails}); // TodoLoaded({required this.data});

  @override
  List<Object> get props => [userDetails];
}

class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState({required this.message});

  @override
  List<Object> get props => [message];
}

class ProfileUnAuthState extends ProfileState {
  final String message;

  const ProfileUnAuthState({required this.message});

  @override
  List<Object> get props => [message];
}