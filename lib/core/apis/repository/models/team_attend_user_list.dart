import 'dart:convert';

List<TeamAttendanceUserItem> teamAttendUserListFromObj(List<dynamic> obj) =>
    List<TeamAttendanceUserItem>.from(
        obj.map((x) => TeamAttendanceUserItem.fromJson(x)));

String presentAbsentUserListToJson(List<TeamAttendanceUserItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


class TeamAttendanceUserItem {
  TeamAttendanceUserItem(
      {this.userId = "0",
      this.date,
      this.name = "",
      this.punchIn,
      this.punchOut,
      this.present = false,
      this.imageUrl,
      this.attStatus = "A",
      this.punchDuration = 0});

  final String userId;
  final DateTime? date;
  final String name;
  final bool present;
  final String? punchIn;
  final String? punchOut;
  final String? imageUrl;
  final String attStatus;
  final double punchDuration;

  factory TeamAttendanceUserItem.fromJson(Map<String, dynamic> json) =>
      TeamAttendanceUserItem(
          userId: json["id"] ?? "",
          date: json["date"]!=null ? DateTime.tryParse(json["date"].toString()) : null,
          name: json["first_name"] != null
              ? "${json['first_name']} ${json['last_name'] ?? ""}"
              : "",
          // present: json["present"] ?? false,
          punchIn: json["punch_in"],
          punchOut: json["punch_out"],
          attStatus: json["att_status"] ?? "A",
          present: json["att_status"] != null &&
                  json["att_status"].toString().toUpperCase().trim() == "P"
              ? true
              : false,

          punchDuration:
              double.tryParse(json["punch_duration"]?.toString() ?? "0") ?? 0,
          imageUrl: json["avatar_uri"]);

  Map<String, dynamic> toJson() => {
        "id": userId,
        "date": date,
        "first_name": name,
        "att_status": attStatus,
        "punch_in": punchIn,
        "punch_out": punchOut,
        "punch_duration": punchDuration,
        "avatar_uri": imageUrl,
      };
}

/*class PresentAbsentUserListResp {
  PresentAbsentUserListResp({
    this.presentAbsentUserList = const [],
  });

  final List<PresentAbsentUserItem> presentAbsentUserList;

  factory PresentAbsentUserListResp.fromJson(Map<String, dynamic> json) =>
      PresentAbsentUserListResp(
        presentAbsentUserList: json["PresentAbsentUserList"] == null
            ? []
            : List<PresentAbsentUserItem>.from(json["PresentAbsentUserList"]
                .map((x) => PresentAbsentUserItem.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "PresentAbsentUserList":
            List<dynamic>.from(presentAbsentUserList.map((x) => x.toJson())),
      };
}*/
/*
class PresentAbsentUserItem {
  PresentAbsentUserItem({
    this.userId,
    this.punchTime,
    this.punchOutTime,
    this.presentAbsent = PresentAbsent.ABSENT,
  });

  final UserId? userId;
  final String? punchTime;
  final String? punchOutTime;
  final PresentAbsent? presentAbsent;

  factory PresentAbsentUserItem.fromJson(Map<String, dynamic> json) =>
      PresentAbsentUserItem(
        userId: json["userId"] == null ? null : UserId.fromJson(json["userId"]),
        punchTime: json["punchTime"] == null ? null : (json["punchTime"]),
        punchOutTime:
            json["punchOutTime"] == null ? null : (json["punchOutTime"]),
        presentAbsent: json["presentabsent"] == null
            ? null
            : presentAbsentValues.map[json["presentabsent"]],
      );

  Map<String, dynamic> toJson() => {
        "userId": userId?.toJson(),
        "punchTime": punchTime,
        "punchOutTime": punchOutTime,
        "presentabsent": presentAbsent == null
            ? null
            : presentAbsentValues.reverse[presentAbsent],
      };
}

enum PresentAbsent { ABSENT, PRESENT }

final presentAbsentValues = EnumValues(
    {"Absent": PresentAbsent.ABSENT, "Present": PresentAbsent.PRESENT});

class UserId {
  UserId({
    this.id = "",
    this.pk = "",
    this.username = "",
    this.userprofile,
  });

  final String id;
  final String pk;
  final String username;
  final Userprofile? userprofile;

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["user_id"],
        pk: json["pk"],
        username: json["full_name"],
        userprofile: json["userprofile"] == null
            ? null
            : Userprofile.fromJson(json["userprofile"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pk": pk,
        "username": username,
        "userprofile": userprofile == null ? null : userprofile!.toJson(),
      };
}

class Userprofile {
  Userprofile({
    required this.firstName,
    required this.lastName,
    this.photo,
    this.currShift
  });

  final String firstName;
  final String lastName;
  final String? photo;
  final CurrShift? currShift;

  factory Userprofile.fromJson(Map<String, dynamic> json) => Userprofile(
        firstName: json["firstName"],
        lastName: json["lastName"],
        photo: json["photo"],
        currShift: json["curShift"] == null
            ? null
            : CurrShift.fromJson(json["curShift"]),
      );

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "photo": photo,
        "curShift": currShift == null ? null : currShift!.toJson(),
      };
}

class CurrShift {
  CurrShift({
    required this.pk,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.gracePeriod,
  });

  final String pk;
  final String name;
  final String startTime;
  final String endTime;
  final int gracePeriod;

  factory CurrShift.fromJson(Map<String, dynamic> json) => CurrShift(
    pk: json["pk"] ?? "",
    name: json["name"] ?? "",
    startTime: json["startTime"] ?? "",
    endTime: json["endTime"] ?? "",
    gracePeriod: json["gracePeriod"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "pk": pk,
    "name": name,
    "startTime": startTime,
    "endTime": endTime,
    "gracePeriod": gracePeriod,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap!;
  }
}*/
