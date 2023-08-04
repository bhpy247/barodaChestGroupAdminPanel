import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class BrochureModel{
  String id = "";
  String brochureName = "";
  String brochureUrl = "";
  Timestamp? createdTime;
  Timestamp? updatedTime;

  BrochureModel({
    this.id = "",
    this.brochureName = "",
    this.brochureUrl = "",
    this.createdTime,
    this.updatedTime,
  });

  BrochureModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    brochureName = ParsingHelper.parseStringMethod(map['brochureName']);
    brochureUrl = ParsingHelper.parseStringMethod(map['brochureUrl']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "brochureName": brochureName,
      "brochureUrl": brochureUrl,
      "createdTime": createdTime,
      "updatedTime": updatedTime,
    };
  }
}