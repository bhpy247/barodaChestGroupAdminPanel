import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class UserCourseEnrollmentModel {
  String courseId = "";
  String lastPlayedChapterId = "";
  int validityInDays = 0;
  Timestamp? activatedDate;
  Timestamp? expiryDate;

  UserCourseEnrollmentModel({
    this.courseId = "",
    this.lastPlayedChapterId = "",
    this.validityInDays = 0,
    this.activatedDate,
    this.expiryDate,
  });

  UserCourseEnrollmentModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    courseId = ParsingHelper.parseStringMethod(map['courseId']);
    lastPlayedChapterId = ParsingHelper.parseStringMethod(map['lastPlayedChapterId']);
    validityInDays = ParsingHelper.parseIntMethod(map['validityInDays']);
    activatedDate = ParsingHelper.parseTimestampMethod(map['activatedDate']);
    expiryDate = ParsingHelper.parseTimestampMethod(map['expiryDate']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "courseId" : courseId,
      "lastPlayedChapterId" : lastPlayedChapterId,
      "validityInDays" : validityInDays,
      "activatedDate" : toJson ? activatedDate?.toDate().millisecondsSinceEpoch : activatedDate,
      "expiryDate" : toJson ? expiryDate?.toDate().millisecondsSinceEpoch : expiryDate,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}