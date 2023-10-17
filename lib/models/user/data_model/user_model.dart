import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../configs/constants.dart';
import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'user_course_enrollment_model.dart';

class UserModel {
  String id = "";
  String name = "";
  String email = "";
  String imageUrl = "";
  String accountType = AccountType.student;
  String speciality = "";
  String mobileNumber = "";
  String hospitalName = "";
  String preference = "";
  String notificationToken = "";
  int age = 0;
  List<String> registeredEvents = [];
  Timestamp? dateOfBirth;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  Map<String, UserCourseEnrollmentModel> myCoursesData = {};

  UserModel({
    this.id = "",
    this.name = "",
    this.email = "",
    this.imageUrl = "",
    this.speciality = "",
    this.mobileNumber = "",
    this.hospitalName = "",
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
    email = ParsingHelper.parseStringMethod(map['email']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    accountType = ParsingHelper.parseStringMethod(map['accountType']);
    speciality = ParsingHelper.parseStringMethod(map['speciality']);
    mobileNumber = ParsingHelper.parseStringMethod(map['mobileNumber']);
    hospitalName = ParsingHelper.parseStringMethod(map['hospitalName']);
    preference = ParsingHelper.parseStringMethod(map['preference']);
    notificationToken = ParsingHelper.parseStringMethod(map['notificationToken']);
    age = ParsingHelper.parseIntMethod(map['age']);
    registeredEvents = ParsingHelper.parseListMethod(map['registeredEvents']);
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
      "id": id,
      "email": email,
      "imageUrl": imageUrl,
      "accountType": accountType,
      "speciality": speciality,
      "mobileNumber": mobileNumber,
      "hospitalName": hospitalName,
      "preference": preference,
      "notificationToken": notificationToken,
      "age": age,
      "registeredEvents": registeredEvents,
      "dateOfBirth": toJson ? dateOfBirth?.toDate().millisecondsSinceEpoch : dateOfBirth,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime": toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
      "myCoursesData": myCoursesData.map<String, Map<String, dynamic>>((key, value) => MapEntry<String, Map<String, dynamic>>(key, value.toMap(toJson: toJson))),
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