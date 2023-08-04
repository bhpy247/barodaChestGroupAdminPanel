import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class CaseOfMonthModel {
  String id = "";
  String caseName = "";
  String description = "";
  String image = "";
  Timestamp? createdTime;
  Timestamp? updatedTime;

  CaseOfMonthModel({
    this.id = "",
    this.caseName = "",
    this.description = "",
    this.image = "",
    this.createdTime,
    this.updatedTime,
  });

  CaseOfMonthModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    caseName = ParsingHelper.parseStringMethod(map['caseName']);
    image = ParsingHelper.parseStringMethod(map['image']);
    description = ParsingHelper.parseStringMethod(map['description']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "caseName": caseName,
      "image": image,
      "description": description,
      "createdTime": createdTime,
      "updatedTime": updatedTime,
    };
  }
}
