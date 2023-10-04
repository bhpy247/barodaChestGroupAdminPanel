import 'dart:convert';
import 'dart:io';

import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/utils/parsing_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/member_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'member_provider.dart';
import 'member_repository.dart';

class MemberController {
  late MemberProvider memberProvider;
  late MemberRepository memberRepository;

  MemberController({required this.memberProvider, MemberRepository? repository}) {
    memberRepository = repository ?? MemberRepository();
  }

  Future<void> getAllMemberList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<MemberModel> memberList = [];
    memberList = await memberRepository.getMemberListRepo();
    if (memberList.isNotEmpty) {
      memberProvider.memberList.setList(list: memberList);
    }
  }

  Future<List<MemberModel>> getMemberPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getMemberPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    MemberProvider provider = memberProvider;

    if (!isRefresh && isFromCache && provider.allMemberLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.memberList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreMember.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastMemberDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isMemberFirstTimeLoading.set(value: true, isNotify: false);
      provider.isMemberLoading.set(value: false, isNotify: false);
      provider.memberList.setList(list: <MemberModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreMember.get()) {
        MyPrint.printOnConsole('No More Member', tag: tag);
        return provider.memberList.getList(isNewInstance: true);
      }
      if (provider.isMemberLoading.get()) return provider.memberList.getList(isNewInstance: true);

      provider.isMemberLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.memberCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastMemberDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Member:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreMember.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastMemberDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<MemberModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          MyPrint.printOnConsole("documentSnapshot.data(): ${documentSnapshot.data()}");
          MemberModel productModel = MemberModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.memberList.setList(list: list, isClear: false, isNotify: false);
      provider.isMemberFirstTimeLoading.set(value: false, isNotify: true);
      provider.isMemberLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Member Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Member Length in Provider:${provider.allMemberLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getMemberPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.memberList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreMember.set(value: true, isNotify: false);
      provider.lastMemberDocument.set(value: null, isNotify: false);
      provider.isMemberFirstTimeLoading.set(value: false, isNotify: false);
      provider.isMemberLoading.set(value: false, isNotify: true);
      return [];
    }
  }

  // Future<void> enableDisableCourseInFirebase({required Map<String, dynamic> editableData, required String id, required int listIndex}) async {
  //   try {
  //     await FirebaseNodes.coursesDocumentReference(courseId: id).update(editableData).then((value) {
  //       MyPrint.printOnConsole("user data: ${editableData["enabled"]}");
  //       courseProvider.updateEnableDisableOfList(editableData["enabled"], listIndex);
  //     });
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in Enable Disable User in firebase in User Controller $e");
  //     MyPrint.printOnConsole(s);
  //   }
  // }

  Future<void> addMemberToFirebase({required MemberModel memberModel, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$memberModel'");

    try {
      await memberRepository.addMemberRepo(memberModel);
      if (isAdInProvider) {
        memberProvider.addMemberModelInCourseList(memberModel);
      } else {
        String title = "Member updated";
        String description = "'${memberModel.name}' Member has been added";
        // String image = memberModel.;
        //
        // NotificationController.sendNotificationMessage2(
        //   title: title,
        //   description: description,
        //   // image: image,
        //   topic: memberModel.id,
        //   data: <String, dynamic>{
        //     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        //     'id': '1',
        //     'objectid': memberModel.id,
        //     'title': title,
        //     'description': description,
        //     'type': NotificationTypes.addedEvent,
        //   },
        // );
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Course to Firebase in Course Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  // Future<List<CourseModel>> getUserMemberList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
  //   String tag = MyUtils.getNewId();
  //   MyPrint.printOnConsole("CourseController().getUserMemberList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
  //
  //   EventProvider provider = courseProvider;
  //
  //   if (!isRefresh) {
  //     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   if (provider.isMyMemberFirstTimeLoading.get()) {
  //     MyPrint.printOnConsole("Returning from CourseController().getUserMemberList() because myMember already fetching", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   MyPrint.printOnConsole("Refresh", tag: tag);
  //   provider.isMyMemberFirstTimeLoading.set(value: true, isNotify: false);
  //   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
  //
  //   try {
  //     List<CourseModel> list = await courseRepository.getMemberListFromIdsList(courseIds: myCourseIds);
  //
  //     provider.events.setList(list: list, isClear: true, isNotify: false);
  //     provider.isMyMemberFirstTimeLoading.set(value: false, isNotify: true);
  //     MyPrint.printOnConsole("Final Member Length From Firestore:${list.length}", tag: tag);
  //     MyPrint.printOnConsole("Final Member Length in Provider:${provider.myMemberLength}", tag: tag);
  //     return list;
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in CourseController().getUserMemberList():$e", tag: tag);
  //     MyPrint.printOnConsole(s, tag: tag);
  //     provider.events.setList(list: [], isClear: true, isNotify: false);
  //     provider.isMyMemberFirstTimeLoading.set(value: false, isNotify: false);
  //     return [];
  //   }
  // }

  Future<void> uploadDataToFirebase() async {
    final String file = await rootBundle.loadString("assets/userList.json");
    final Map<String, dynamic> jsonMap  = await json.decode(file);
    TempModel tempModel = TempModel.fromJson(jsonMap);

    List<MemberModel> memberList = [];
    tempModel.sheet1!.forEach((element) {

      memberList.add(MemberModel(
        id: MyUtils.getNewId(isFromUUuid: false),
        name: element.column4??"",
        email: element.column7 ?? "",
        designation: element.column6 ?? "",
        mobile: ParsingHelper.parseIntMethod(element.column8),
        createdTime: Timestamp.now()
      ));
    });

    // addMemberToFirebase();
    memberList.forEach((element) {
      addMemberToFirebase(memberModel: element,isAdInProvider: true);
      MyPrint.printOnConsole("Json Map: ${element.toMap()}");
    });

  }


}


class TempModel {
  List<Sheet1>? sheet1;
  List<Sheet2>? sheet2;
  List<Null>? sheet3;

  TempModel({this.sheet1, this.sheet2, this.sheet3});

  TempModel.fromJson(Map<String, dynamic> json) {
    if (json['Sheet1'] != null) {
      sheet1 = <Sheet1>[];
      json['Sheet1'].forEach((v) {
        sheet1!.add(Sheet1.fromJson(v));
      });
    }
    if (json['Sheet2'] != null) {
      sheet2 = <Sheet2>[];
      json['Sheet2'].forEach((v) {
        sheet2!.add(Sheet2.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sheet1 != null) {
      data['Sheet1'] = sheet1!.map((v) => v.toJson()).toList();
    }
    if (sheet2 != null) {
      data['Sheet2'] = sheet2!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Sheet1 {
  int? column1;
  String? column2;
  String? column3;
  String? column4;
  String? bCGMembers;
  String? column6;
  String? column7;
  int? column8;

  Sheet1(
      {this.column1,
        this.column2,
        this.column3,
        this.column4,
        this.bCGMembers,
        this.column6,
        this.column7,
        this.column8});

  Sheet1.fromJson(Map<String, dynamic> json) {
    column1 = json['Column1'];
    column2 = json['Column2'];
    column3 = json['Column3'];
    column4 = json['Column4'];
    bCGMembers = json['BCG Members '];
    column6 = json['Column6'];
    column7 = json['Column7'];
    column8 = json['Column8'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Column1'] = column1;
    data['Column2'] = column2;
    data['Column3'] = column3;
    data['Column4'] = column4;
    data['BCG Members '] = bCGMembers;
    data['Column6'] = column6;
    data['Column7'] = column7;
    data['Column8'] = column8;
    return data;
  }
}

class Sheet2 {
  String? l001;
  String? drAgamSrivastav;

  Sheet2({this.l001, this.drAgamSrivastav});

  Sheet2.fromJson(Map<String, dynamic> json) {
    l001 = json['L-001'];
    drAgamSrivastav = json['Dr. Agam Srivastav'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['L-001'] = l001;
    data['Dr. Agam Srivastav'] = drAgamSrivastav;
    return data;
  }
}
