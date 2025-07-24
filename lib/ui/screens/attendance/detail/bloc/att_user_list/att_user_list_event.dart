part of 'att_user_list_bloc.dart';

abstract class AttUserListEvent extends Equatable {
  const AttUserListEvent();
}

class AttUserListInitEvent extends AttUserListEvent {
  final String startDate;
  final String endDate;
  final String? search;
  final String? userType;
  final List<TeamItem> teamList;

  const AttUserListInitEvent({required this.startDate, required this.endDate,
   this.teamList = const[], this.search, this.userType});

  @override
  List<Object?> get props => [startDate, endDate, teamList, search, userType];
}

class AttTeamListInitEvent extends AttUserListEvent {

  const AttTeamListInitEvent();

  @override
  List<Object> get props => [];
}