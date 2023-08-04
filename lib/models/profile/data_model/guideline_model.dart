import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class GuidelineModel {
  String id = "";
  String name = "";
  String downloadUrl = "";
  Timestamp? createdTime;


  GuidelineModel({
    this.id = "",
    this.name = "",
    this.downloadUrl = "",
    this.createdTime,

  });
  GuidelineModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);

    name = ParsingHelper.parseStringMethod(map['name']);
    downloadUrl = ParsingHelper.parseStringMethod(map['downloadurl']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "downloadurl": downloadUrl,
      "createdTime": createdTime,
    };
  }
}
