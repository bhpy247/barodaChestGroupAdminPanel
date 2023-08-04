import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class MemberModel {
  String id = "";
  String name = "";
  String designation = "";
  String email = "";
  String address = "";
  Timestamp? createdTime;


  MemberModel({
    this.id = "",
    this.name = "",
    this.designation = "",
    this.email = "",
    this.address = "",
    this.createdTime,

  });
  MemberModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    email = ParsingHelper.parseStringMethod(map['email']);
    designation = ParsingHelper.parseStringMethod(map['designation']);
    address = ParsingHelper.parseStringMethod(map['address']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "email": email,
      "address": address,
      "designation": designation,
      "createdTime": createdTime,
    };
  }
}
