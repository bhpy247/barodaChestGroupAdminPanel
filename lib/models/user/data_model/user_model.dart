import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../utils/my_utils.dart';
import '../../../../utils/parsing_helper.dart';
import 'user_course_enrollment_model.dart';

class UserModel {
  String id = "";
  String name = "";
  String imageUrl = "";
  String mobileNumber = "";
  String preference = "";
  String notificationToken = "";
  int age = 0;
  Timestamp? dateOfBirth;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  Map<String, UserCourseEnrollmentModel> myCoursesData = {};

  UserModel({
    this.id = "",
    this.name = "",
    this.imageUrl = "",
    this.mobileNumber = "",
    this.preference = "",
    this.notificationToken = "",
    this.age = 0,
    this.dateOfBirth,
    this.createdTime,
    this.updatedTime,
    Map<String, UserCourseEnrollmentModel>? myCoursesData,
  }) {
    this.myCoursesData = myCoursesData ?? <String, UserCourseEnrollmentModel>{};
  }

  UserModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    preference = ParsingHelper.parseStringMethod(map['preference']);
    notificationToken = ParsingHelper.parseStringMethod(map['notificationToken']);
    age = ParsingHelper.parseIntMethod(map['age']);
    dateOfBirth = ParsingHelper.parseTimestampMethod(map['dateOfBirth']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    myCoursesData.clear();
    Map<String, dynamic> myCoursesDataMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(map['myCoursesData']);
    myCoursesData.addAll(myCoursesDataMap.map((String courseId, dynamic value) {
      Map<String, dynamic> courseDataMap = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(value);
      return MapEntry<String, UserCourseEnrollmentModel>(courseId, UserCourseEnrollmentModel.fromMap(courseDataMap));
    }));
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "name" : name,
      "imageUrl" : imageUrl,
      "mobileNumber" : mobileNumber,
      "preference" : preference,
      "notificationToken" : notificationToken,
      "age" : age,
      "dateOfBirth" : toJson ? dateOfBirth?.toDate().millisecondsSinceEpoch : dateOfBirth,
      "createdTime" : toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "myCoursesData" : myCoursesData.map<String, Map<String, dynamic>>((key, value) => MapEntry<String, Map<String, dynamic>>(key, value.toMap(toJson: toJson))),
    };
  }

  bool checkIsCourseEnrolled({required String courseId}) {
    if(courseId.isEmpty) {
      return false;
    }

    UserCourseEnrollmentModel? userCourseEnrollmentModel = myCoursesData[courseId];
    return userCourseEnrollmentModel != null;
  }

  bool checkIsActiveCourse({required String courseId, required DateTime? now}) {
    if(!checkIsCourseEnrolled(courseId: courseId)) {
      return false;
    }

    UserCourseEnrollmentModel? userCourseEnrollmentModel = myCoursesData[courseId];
    DateTime? expiryDate = userCourseEnrollmentModel?.expiryDate?.toDate();
    if(expiryDate == null || now == null) {
      return false;
    }

    return expiryDate.isAfter(now);
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}