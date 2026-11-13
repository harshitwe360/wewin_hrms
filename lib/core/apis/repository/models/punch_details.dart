import 'dart:convert';

PunchDetails punchDetailsFromObj(Map<String, dynamic> obj) =>
    PunchDetails.fromJson(obj);

PunchDetails punchDetailsFromJson(String str) =>
    PunchDetails.fromJson(json.decode(str));

String punchDetailsToJson(PunchDetails data) => json.encode(data.toJson());

class PunchDetails {
  PunchDetails({
    this.userInOutByUser,
    this.currentUserPunchIn,
  });

  final List<UserInOutByUser>? userInOutByUser;
  final List<CurrentUserPunchIn>? currentUserPunchIn;

  factory PunchDetails.fromJson(Map<String, dynamic> json) => PunchDetails(
        userInOutByUser: json["UserInOutByUser"] == null
            ? null
            : List<UserInOutByUser>.from(json["UserInOutByUser"]
                .map((x) => UserInOutByUser.fromJson(x))),
        currentUserPunchIn: json["CurrentUserPunchIn"] == null
            ? null
            : List<CurrentUserPunchIn>.from(json["CurrentUserPunchIn"]
                .map((x) => CurrentUserPunchIn.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "UserInOutByUser": userInOutByUser == null
            ? null
            : List<dynamic>.from(userInOutByUser!.map((x) => x.toJson())),
        "CurrentUserPunchIn": currentUserPunchIn == null
            ? null
            : List<dynamic>.from(currentUserPunchIn!.map((x) => x.toJson())),
      };
}

class CurrentUserPunchIn {
  CurrentUserPunchIn({
    this.punchIn = "",
    this.punchOut = "",
    this.pk = "",
  });

  final String punchIn;
  final String punchOut;
  final String pk;

  factory CurrentUserPunchIn.fromJson(Map<String, dynamic> json) =>
      CurrentUserPunchIn(
        punchIn: json["punchIn"] ?? "",
        punchOut: json["punchOut"] ?? "",
        pk: json["pk"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "punchIn": punchIn,
        "punchOut": punchOut,
        "pk": pk,
      };
}

class UserInOutByUser {
  UserInOutByUser({
    this.id = "",
    this.userId,
    this.punchIn = "",
    this.punchOut = "",
    this.pk = "",
  });

  final String id;
  final UserId? userId;
  final String punchIn;
  final String punchOut;
  final String pk;

  factory UserInOutByUser.fromJson(Map<String, dynamic> json) =>
      UserInOutByUser(
        id: json["id"] ?? "",
        userId:
            json["userId"] == null ? UserId() : UserId.fromJson(json["userId"]),
        punchIn: json["punchIn"] ?? "",
        punchOut: json["punchOut"] ?? "",
        pk: json["pk"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId?.toJson(),
        "punchIn": punchIn,
        "punchOut": punchOut,
        "pk": pk,
      };
}

class UserId {
  UserId({
    this.id = "",
    this.pk = "",
    this.username = "",
  });

  final String id;
  final String pk;
  final String username;

  factory UserId.fromJson(Map<String, dynamic> json) => UserId(
        id: json["id"] ?? "",
        pk: json["pk"] ?? "",
        username: json["username"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "pk": pk,
        "username": username,
      };
}
