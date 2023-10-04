import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class MembershipModel {
  String id = "";
  String name = "";
  String email = "";
  String gender = "", qualification = "", whyWantToBeMember = "", reference = "";
  int mobile = 0, age = 0;

  Timestamp? createdTime;

  MembershipModel({
    this.id = "",
    this.name = "",
    this.email = "",
    this.qualification = "",
    this.whyWantToBeMember = "",
    this.reference = "",
    this.mobile = 0,
    this.gender = "",
    this.age = 0,
    this.createdTime,
  });

  MembershipModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);

    name = ParsingHelper.parseStringMethod(map['name']);
    email = ParsingHelper.parseStringMethod(map['email']);
    qualification = ParsingHelper.parseStringMethod(map['qualification']);
    whyWantToBeMember = ParsingHelper.parseStringMethod(map['whyWantToBeMember']);
    gender = ParsingHelper.parseStringMethod(map['gender']);
    reference = ParsingHelper.parseStringMethod(map['reference']);
    mobile = ParsingHelper.parseIntMethod(map['mobile']);
    age = ParsingHelper.parseIntMethod(map['age']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "gender": gender,
      "reference": reference,
      "qualification": qualification,
      "whyWantToBeMember": whyWantToBeMember,
      "age": age,
      "email": email,
      "mobile": mobile,
      "createdTime": createdTime,
    };
  }
}
