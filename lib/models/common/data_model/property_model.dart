import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class PropertyModel {
  String aboutDescription = "", contactNumber = "", whatsApp = "", termsAndConditionsUrl = "", privacyAndPolicyUrl = "";
  String enrollCourseContactNumber = "";
  bool notificationsEnabled = false, subscriptionDeleteEnabled = false, enableEnrollment = false;
  List<String> sliders = [];


  PropertyModel({
    this.aboutDescription = "",
    this.contactNumber = "",
    this.whatsApp = "",
    this.sliders = const  [],
    this.termsAndConditionsUrl = "",
    this.privacyAndPolicyUrl = "",
    this.enrollCourseContactNumber = "",
    this.notificationsEnabled = false,
    this.subscriptionDeleteEnabled = false,
    this.enableEnrollment = false,
  });

  PropertyModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    sliders = ParsingHelper.parseListMethod<dynamic, String>(map['sliders']);
    aboutDescription = ParsingHelper.parseStringMethod(map['aboutDescription']);
    contactNumber = ParsingHelper.parseStringMethod(map['contactNumber']);
    whatsApp = ParsingHelper.parseStringMethod(map['whatsApp']);
    termsAndConditionsUrl = ParsingHelper.parseStringMethod(map['termsAndConditionsUrl']);
    privacyAndPolicyUrl = ParsingHelper.parseStringMethod(map['privacyAndPolicyUrl']);
    enrollCourseContactNumber = ParsingHelper.parseStringMethod(map['enrollCourseContactNumber']);
    notificationsEnabled = ParsingHelper.parseBoolMethod(map['notificationsEnabled']);
    subscriptionDeleteEnabled = ParsingHelper.parseBoolMethod(map['subscriptionDeleteEnabled']);
    if(!kIsWeb && Platform.isIOS){
      enableEnrollment = ParsingHelper.parseBoolMethod(map['enableEnrollment']);
    }
    else {
      enableEnrollment = true;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "sliders": sliders,
      "aboutDescription": aboutDescription,
      "contactNumber": contactNumber,
      "whatsApp": whatsApp,
      "termsAndConditionsUrl": termsAndConditionsUrl,
      "privacyAndPolicyUrl": privacyAndPolicyUrl,
      "enrollCourseContactNumber": enrollCourseContactNumber,
      "notificationsEnabled": notificationsEnabled,
      "subscriptionDeleteEnabled": subscriptionDeleteEnabled,
      "enableEnrollment": enableEnrollment,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}