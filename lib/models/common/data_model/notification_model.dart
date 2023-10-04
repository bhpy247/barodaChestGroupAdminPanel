import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class NotificationModel {
  String title = "", notificationType = "", imageUrl = "", description = "", id = "";
  Timestamp? createdTime;

  NotificationModel({
    this.title = "",
    this.description = "",
    this.createdTime,
    this.notificationType = "",
    this.imageUrl = "",
    this.id = ""
  });

  NotificationModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    title = ParsingHelper.parseStringMethod(map['title']);
    id = ParsingHelper.parseStringMethod(map['id']);
    description = ParsingHelper.parseStringMethod(map['description']);
    notificationType = ParsingHelper.parseStringMethod(map['notificationType']);
    imageUrl = ParsingHelper.parseStringMethod(map['image']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "imageUrl" : imageUrl,
      "notificationType" : notificationType,
      "description" : description,
      "createdTime" : createdTime,
    };
  }
}
