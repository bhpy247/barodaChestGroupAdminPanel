import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class ContactUsModel {
  String id = "";
  String name = "";
  String email = "";
  String message = "";
  int mobile = 0;
  Timestamp? createdTime;


  ContactUsModel({
    this.id = "",
    this.name = "",
    this.email = "",
    this.message = "",
    this.mobile = 0,
    this.createdTime,

  });
  ContactUsModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);

    name = ParsingHelper.parseStringMethod(map['name']);
    message = ParsingHelper.parseStringMethod(map['message']);
    email = ParsingHelper.parseStringMethod(map['email']);
    mobile = ParsingHelper.parseIntMethod(map['mobile']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "message":message,
      "name": name,
      "email": email,
      "mobile": mobile,
      "createdTime": createdTime,
    };
  }
}
