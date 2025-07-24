import 'dart:convert';

List<DdModel> ddListFromObjJson(List<dynamic> obj) =>
    List<DdModel>.from(obj.map((x) => DdModel.fromJson(x)));

class DdModel {
  String id;
  String? nameEng;
  String? nameHindi;

  DdModel({
    required this.id,
    this.nameEng,
    this.nameHindi,
  });

  factory DdModel.fromRawJson(String str) => DdModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DdModel.fromJson(Map<String, dynamic> json) => DdModel(
    id: (json["id"] ?? "0").toString(),
    nameEng: json["name"],
    nameHindi: json["nameHindi"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": nameEng,
    "nameHindi": nameHindi,
  };
}