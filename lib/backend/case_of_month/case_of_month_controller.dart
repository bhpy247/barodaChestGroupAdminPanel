
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/models/event/data_model/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/common/data_model/notification_model.dart';
import '../../models/course/data_model/course_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'case_of_month_provider.dart';
import 'case_of_month_repository.dart';

class CaseOfMonthController {
  late CaseOfMonthProvider caseOfMonthProvider;
  late CaseOfMonthRepository caseOfMonthRepository;

  CaseOfMonthController({required this.caseOfMonthProvider, CaseOfMonthRepository? repository}) {
    caseOfMonthRepository = repository ?? CaseOfMonthRepository();
  }

  Future<void> getAllCaseOfMonthList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<CaseOfMonthModel> coursesList = [];
    coursesList = await caseOfMonthRepository.getCaseOfMonthListRepo();
    if (coursesList.isNotEmpty) {
      caseOfMonthProvider.caseOfMonthList.setList(list: coursesList);
    }
  }

  Future<List<CaseOfMonthModel>> getCaseOfMonthPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getCaseOfMonthPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    CaseOfMonthProvider provider = caseOfMonthProvider;

    if (!isRefresh && isFromCache && provider.allCaseOfMonthLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.caseOfMonthList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreCaseOfMonth.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastCourseDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isCaseOfMonthFirstTimeLoading.set(value: true, isNotify: false);
      provider.isCaseOfMonthLoading.set(value: false, isNotify: false);
      provider.caseOfMonthList.setList(list: <CaseOfMonthModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreCaseOfMonth.get()) {
        MyPrint.printOnConsole('No More CaseOfMonth', tag: tag);
        return provider.caseOfMonthList.getList(isNewInstance: true);
      }
      if (provider.isCaseOfMonthLoading.get()) return provider.caseOfMonthList.getList(isNewInstance: true);

      provider.isCaseOfMonthLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.caseOfMonthCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastCourseDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for CaseOfMonth:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreCaseOfMonth.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastCourseDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<CaseOfMonthModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          CaseOfMonthModel productModel = CaseOfMonthModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.caseOfMonthList.setList(list: list, isClear: false, isNotify: false);
      provider.isCaseOfMonthFirstTimeLoading.set(value: false, isNotify: true);
      provider.isCaseOfMonthLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final CaseOfMonth Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final CaseOfMonth Length in Provider:${provider.allCaseOfMonthLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getCaseOfMonthPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.caseOfMonthList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreCaseOfMonth.set(value: true, isNotify: false);
      provider.lastCourseDocument.set(value: null, isNotify: false);
      provider.isCaseOfMonthFirstTimeLoading.set(value: false, isNotify: false);
      provider.isCaseOfMonthLoading.set(value: false, isNotify: true);
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

  Future<void> addCaseOfMonthToFirebase({required CaseOfMonthModel caseOfMonth, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$caseOfMonth'");

    try {
      await caseOfMonthRepository.addCaseOfMonthRepo(caseOfMonth);
      if (isAdInProvider) {
        caseOfMonthProvider.addCaseOfMonthModelInCourseList(caseOfMonth);
        String title = "Case of month added";
        String description = "'${caseOfMonth.caseName}' Case of month has been added";
        String image = caseOfMonth.image;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: NotificationTopicType.admin,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': caseOfMonth.id,
            'title': title,
            'description': description,
            'type': NotificationTypes.caseOfMonth,
            'imageurl': image,
          },
        );
        NotificationModel notificationModel = NotificationModel(
          createdTime: Timestamp.now(),
          title: caseOfMonth.caseName,
          id: MyUtils.getNewId(),
          description: caseOfMonth.description,
          notificationType: NotificationTypes.caseOfMonth,
        );
        NotificationController().addNotificationToFirebase(notificationModel);
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Course to Firebase in Course Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  // Future<List<CourseModel>> getUserCaseOfMonthList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
  //   String tag = MyUtils.getNewId();
  //   MyPrint.printOnConsole("CourseController().getUserCaseOfMonthList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
  //
  //   EventProvider provider = courseProvider;
  //
  //   if (!isRefresh) {
  //     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   if (provider.isMyCaseOfMonthFirstTimeLoading.get()) {
  //     MyPrint.printOnConsole("Returning from CourseController().getUserCaseOfMonthList() because myCaseOfMonth already fetching", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   MyPrint.printOnConsole("Refresh", tag: tag);
  //   provider.isMyCaseOfMonthFirstTimeLoading.set(value: true, isNotify: false);
  //   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
  //
  //   try {
  //     List<CourseModel> list = await courseRepository.getCaseOfMonthListFromIdsList(courseIds: myCourseIds);
  //
  //     provider.events.setList(list: list, isClear: true, isNotify: false);
  //     provider.isMyCaseOfMonthFirstTimeLoading.set(value: false, isNotify: true);
  //     MyPrint.printOnConsole("Final CaseOfMonth Length From Firestore:${list.length}", tag: tag);
  //     MyPrint.printOnConsole("Final CaseOfMonth Length in Provider:${provider.myCaseOfMonthLength}", tag: tag);
  //     return list;
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in CourseController().getUserCaseOfMonthList():$e", tag: tag);
  //     MyPrint.printOnConsole(s, tag: tag);
  //     provider.events.setList(list: [], isClear: true, isNotify: false);
  //     provider.isMyCaseOfMonthFirstTimeLoading.set(value: false, isNotify: false);
  //     return [];
  //   }
  // }
}
