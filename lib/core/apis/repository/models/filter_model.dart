import 'package:flutter/material.dart';

import 'team_model.dart';

@immutable
class FilterModel {
  final String startDate;
  final String endDate;
  final String? userType;
  final String? search;
  final List<TeamItem> groups;
  final String? userId;

  const FilterModel(
      {this.startDate = "",
      this.endDate = "",
      this.userType = "all",
      this.search = "",
      this.groups = const [],
        this.userId = ""
      });

  FilterModel copyWith({
    String? startDate,
    String? endDate,
    String? userType,
    String? search,
    List<TeamItem>? groups,
    String? userId
  }) => FilterModel(
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        groups: groups ?? this.groups,
        search: search ?? this.search,
        userType: userType ?? this.userType,
        userId: userId ?? this.userId
    );

  /*String? get getStartDate => startDate;

  set setStartDate(String startData) {
    startDate = startDate;
  }*/

}
