part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class GetUserDetails extends ProfileEvent {
  const GetUserDetails();

  @override
  List<Object> get props => [];
}