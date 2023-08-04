import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class EventModel {
  String id = "";
  String title = "";
  String address = "";
  String description = "";
  String imageUrl = "";
  int totalSeats = 0;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  Timestamp? eventStartDate;
  Timestamp? eventEndDate;

  EventModel({
    this.id = "",
    this.title = "",
    this.address = "",
    this.description = "",
    this.totalSeats = 0,
    this.imageUrl = "",
    this.createdTime,
    this.updatedTime,
    this.eventEndDate,
    this.eventStartDate
  });

  EventModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    address = ParsingHelper.parseStringMethod(map['address']);
    title = ParsingHelper.parseStringMethod(map['title']);
    totalSeats = ParsingHelper.parseIntMethod(map['totalSeats']);
    description = ParsingHelper.parseStringMethod(map['description']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    eventStartDate = ParsingHelper.parseTimestampMethod(map['eventStartDate']);
    eventEndDate = ParsingHelper.parseTimestampMethod(map['eventEndDate']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "imageUrl" : imageUrl,
      "address" : address,
      "description" : description,
      "createdTime" : createdTime,
      "totalSeats" : totalSeats,
      "updatedTime" : updatedTime,
      "eventStartDate" : eventStartDate,
      "eventEndDate" : eventEndDate,
    };
  }
}
