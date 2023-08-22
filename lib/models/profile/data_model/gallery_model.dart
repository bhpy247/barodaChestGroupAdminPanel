import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/parsing_helper.dart';

class GalleryModel {
  String id = "";
  String eventName = "";
  String description = "";
  Timestamp? createdTime;
  Timestamp? eventDate;
  List<String> imageList = [];


   GalleryModel({
    this.id = "",
    this.eventName = "",
    this.description = "",
    this.createdTime,
    this.eventDate,
     this.imageList = const  [],

  });
   GalleryModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    imageList = ParsingHelper.parseListMethod<dynamic, String>(map['imageUrlList']);
    eventName = ParsingHelper.parseStringMethod(map['eventName']);
    description = ParsingHelper.parseStringMethod(map['description']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    eventDate = ParsingHelper.parseTimestampMethod(map['eventDate']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "imageUrlList": imageList,
      "eventName": eventName,
      "description": description,
      "createdTime": createdTime,
      "eventData": eventDate,
    };
  }
}
