import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class EventModel {
  String id = "";
  String title = "";
  String address = "";
  String description = "";
  String imageUrl = "";
  String pdfUrl = "";
  String youtubeUrl = "";
  String eventType = "";
  int totalSeats = 0;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  Timestamp? eventStartDate;
  Timestamp? eventEndDate;
  List<String> registeredUser = [];

  EventModel(
      {this.id = "",
      this.title = "",
      this.address = "",
      this.description = "",
      this.totalSeats = 0,
      this.eventType = "",
      this.imageUrl = "",
      this.pdfUrl = "",
      this.youtubeUrl = "",
      this.createdTime,
      this.updatedTime,
      this.eventEndDate,
      this.eventStartDate,
      this.registeredUser = const []});

  EventModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    pdfUrl = ParsingHelper.parseStringMethod(map['pdfUrl']);
    youtubeUrl = ParsingHelper.parseStringMethod(map['youtubeUrl']);
    address = ParsingHelper.parseStringMethod(map['address']);
    title = ParsingHelper.parseStringMethod(map['title']);
    eventType = ParsingHelper.parseStringMethod(map['eventType']);
    totalSeats = ParsingHelper.parseIntMethod(map['totalSeats']);
    description = ParsingHelper.parseStringMethod(map['description']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    registeredUser = ParsingHelper.parseListMethod(map['registeredUser']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
    eventStartDate = ParsingHelper.parseTimestampMethod(map['eventStartDate']);
    eventEndDate = ParsingHelper.parseTimestampMethod(map['eventEndDate']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "title": title,
      "eventType": eventType,
      "imageUrl": imageUrl,
      "pdfUrl": pdfUrl,
      "address": address,
      "youtubeUrl": youtubeUrl,
      "registeredUser": registeredUser,
      "description": description,
      "createdTime": createdTime,
      "totalSeats": totalSeats,
      "updatedTime": updatedTime,
      "eventStartDate": eventStartDate,
      "eventEndDate": eventEndDate,
    };
  }
}
