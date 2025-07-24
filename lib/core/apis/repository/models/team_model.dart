import 'dart:convert';

List<TeamItem> teamListFromObj(List<dynamic> obj) =>
    List<TeamItem>.from(obj.map((x) => TeamItem.fromJson(x)));

String teamListToJson(List<TeamItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// TeamModel teamModelFromJson(String str) => TeamModel.fromJson(json.decode(str));

// String teamModelToJson(TeamModel data) => json.encode(data.toJson());

TeamItem teamItemFromJson(String str) => TeamItem.fromJson(json.decode(str));

String teamItemToJson(TeamItem data) => json.encode(data.toJson());

/*class TeamModel {
  TeamModel({
    required this.teamItem,
  });

  final List<TeamItem> teamItem;

  factory TeamModel.fromJson(Map<String, dynamic> json) => TeamModel(
    teamItem: List<TeamItem>.from(json["data"].map((x) => TeamItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(teamItem.map((x) => x.toJson())),
  };
}*/

class TeamItem {
  TeamItem({
    required this.id,
    required this.name,
    // required this.description,
    // required this.isActive,
    // required this.updateAllow,
  });

  final String id;
  final String name;
  // final String description;
  // final bool isActive;
  // final bool updateAllow;

  factory TeamItem.fromJson(Map<String, dynamic> json) => TeamItem(
    id: json["id"],
    name: json["name"],
    // description: json["description"],
    // isActive: json["is_active"],
    // updateAllow: json["update_allow"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    // "description": description,
    // "is_active": isActive,
    // "update_allow": updateAllow,
  };
}
