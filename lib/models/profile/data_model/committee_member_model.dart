import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class CommitteeMemberModel {
  String id = "";
  String name = "";
  String profileUrl = "";
  String type = "";
  Timestamp? createdTime;


  CommitteeMemberModel({
    this.id = "",
    this.name = "",
    this.profileUrl = "",
    this.type = "",
    this.createdTime,

  });
  CommitteeMemberModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    type = ParsingHelper.parseStringMethod(map['type']);
    profileUrl = ParsingHelper.parseStringMethod(map['profileUrl']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "type": type,
      "profileUrl": profileUrl,
      "createdTime": createdTime,
    };
  }
}
