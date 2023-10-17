import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/common/data_model/notification_model.dart';
import '../../models/profile/data_model/guideline_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'guideline_provider.dart';
import 'guideline_repository.dart';

class GuidelineController {
  late GuidelineProvider guidelineProvider;
  late GuidelineRepository guidelineRepository;

  GuidelineController({required this.guidelineProvider, GuidelineRepository? repository}) {
    guidelineRepository = repository ?? GuidelineRepository();
  }

  Future<void> getAllGuidelineList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<GuidelineModel> guidelineList = [];
    guidelineList = await guidelineRepository.getGuidelineListRepo();
    if (guidelineList.isNotEmpty) {
      guidelineProvider.guidelineList.setList(list: guidelineList);
    }
  }

  Future<List<GuidelineModel>> getGuidelinePaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getGuidelinePaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    GuidelineProvider provider = guidelineProvider;

    if (!isRefresh && isFromCache && provider.alGuidelineLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.guidelineList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreGuideline.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastGuidelineDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isGuidelineFirstTimeLoading.set(value: true, isNotify: false);
      provider.isGuidelineLoading.set(value: false, isNotify: false);
      provider.guidelineList.setList(list: <GuidelineModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreGuideline.get()) {
        MyPrint.printOnConsole('No More Guideline', tag: tag);
        return provider.guidelineList.getList(isNewInstance: true);
      }
      if (provider.isGuidelineLoading.get()) return provider.guidelineList.getList(isNewInstance: true);

      provider.isGuidelineLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.guidelineCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastGuidelineDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Guideline:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreGuideline.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastGuidelineDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<GuidelineModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          GuidelineModel productModel = GuidelineModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.guidelineList.setList(list: list, isClear: false, isNotify: false);
      provider.isGuidelineFirstTimeLoading.set(value: false, isNotify: true);
      provider.isGuidelineLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Guideline Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Guideline Length in Provider:${provider.alGuidelineLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getGuidelinePaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.guidelineList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreGuideline.set(value: true, isNotify: false);
      provider.lastGuidelineDocument.set(value: null, isNotify: false);
      provider.isGuidelineFirstTimeLoading.set(value: false, isNotify: false);
      provider.isGuidelineLoading.set(value: false, isNotify: true);
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

  Future<void> addGuidelineToFirebase({required GuidelineModel guideline, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$guideline'");

    try {
      await guidelineRepository.addGuidelineRepo(guideline);
      if (isAdInProvider) {
        guidelineProvider.addGuidelineModelInCourseList(guideline);
      }
      String title = "New Guideline ${isAdInProvider ? "Added" : "Updated"}";
      String description = "'${guideline.name}' guideline has been ${isAdInProvider ? "Added" : "Updated"}";
      String image = guideline.downloadUrl;

      NotificationController.sendNotificationMessage2(
        title: title,
        description: description,
        image: image,
        topic: NotificationTopicType.admin,
        data: <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'objectid': guideline.id,
          'title': title,
          'description': description,
          'type': NotificationTopicType.admin,
          'imageurl': image,
        },
      );
      NotificationModel notificationModel = NotificationModel(
        createdTime: Timestamp.now(),
        title: title,
        id: MyUtils.getNewId(),
        description: guideline.downloadUrl,
        notificationType: NotificationTypes.guideLine,
      );
      NotificationController().addNotificationToFirebase(notificationModel);
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add GuideLine to Firebase in GuideLine Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  // Future<List<CourseModel>> getUserGuidelineList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
  //   String tag = MyUtils.getNewId();
  //   MyPrint.printOnConsole("CourseController().getUserGuidelineList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
  //
  //   EventProvider provider = courseProvider;
  //
  //   if (!isRefresh) {
  //     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   if (provider.isMyGuidelineFirstTimeLoading.get()) {
  //     MyPrint.printOnConsole("Returning from CourseController().getUserGuidelineList() because myGuideline already fetching", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   MyPrint.printOnConsole("Refresh", tag: tag);
  //   provider.isMyGuidelineFirstTimeLoading.set(value: true, isNotify: false);
  //   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
  //
  //   try {
  //     List<CourseModel> list = await courseRepository.getGuidelineListFromIdsList(courseIds: myCourseIds);
  //
  //     provider.events.setList(list: list, isClear: true, isNotify: false);
  //     provider.isMyGuidelineFirstTimeLoading.set(value: false, isNotify: true);
  //     MyPrint.printOnConsole("Final Guideline Length From Firestore:${list.length}", tag: tag);
  //     MyPrint.printOnConsole("Final Guideline Length in Provider:${provider.myGuidelineLength}", tag: tag);
  //     return list;
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in CourseController().getUserGuidelineList():$e", tag: tag);
  //     MyPrint.printOnConsole(s, tag: tag);
  //     provider.events.setList(list: [], isClear: true, isNotify: false);
  //     provider.isMyGuidelineFirstTimeLoading.set(value: false, isNotify: false);
  //     return [];
  //   }
  // }
}
