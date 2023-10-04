import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class CaseOfMonthModel {
  String id = "";
  String caseName = "";
  String description = "";
  String downloadUrl = "";
  String image = "";
  Timestamp? createdTime;
  Timestamp? updatedTime;
  Timestamp? caseOfMonthDate;

  CaseOfMonthModel({
    this.id = "",
    this.caseName = "",
    this.description = "",
    this.downloadUrl = "",
    this.caseOfMonthDate,
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
    downloadUrl = ParsingHelper.parseStringMethod(map['downloadUrl']);
    description = ParsingHelper.parseStringMethod(map['description']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    caseOfMonthDate = ParsingHelper.parseTimestampMethod(map['caseOfMonthDate']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "caseName": caseName,
      "image": image,
      "downloadUrl": downloadUrl,
      "description": description,
      "caseOfMonthDate": caseOfMonthDate,
      "createdTime": createdTime,
      "updatedTime": updatedTime,
    };
  }
}
