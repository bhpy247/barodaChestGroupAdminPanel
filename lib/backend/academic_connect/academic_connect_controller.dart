import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'academic_connect_provider.dart';
import 'academic_connect_repository.dart';

class AcademicConnectController {
  late AcademicConnectProvider academicConnectProvider;
  late AcademicConnectRepository academicConnectRepository;

  AcademicConnectController({required this.academicConnectProvider, AcademicConnectRepository? repository}) {
    academicConnectRepository = repository ?? AcademicConnectRepository();
  }

  Future<void> getAllCourseList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<AcademicConnectModel> coursesList = [];
    coursesList = await academicConnectRepository.getAcademicConnectListRepo();
    if (coursesList.isNotEmpty) {
      academicConnectProvider.allEvent.setList(list: coursesList);
    }
  }

  Future<List<AcademicConnectModel>> getAcademicConnectPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getAcademicConnectPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    AcademicConnectProvider provider = academicConnectProvider;

    if (!isRefresh && isFromCache && provider.allAcademicConnectLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.allEvent.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreAcademicConnect.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastCourseDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isAcademicConnectFirstTimeLoading.set(value: true, isNotify: false);
      provider.isAcademicConnectLoading.set(value: false, isNotify: false);
      provider.allEvent.setList(list: <AcademicConnectModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreAcademicConnect.get()) {
        MyPrint.printOnConsole('No More AcademicConnect', tag: tag);
        return provider.allEvent.getList(isNewInstance: true);
      }
      if (provider.isAcademicConnectLoading.get()) return provider.allEvent.getList(isNewInstance: true);

      provider.isAcademicConnectLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.academicConnectCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastCourseDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for AcademicConnect:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreAcademicConnect.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastCourseDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<AcademicConnectModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          AcademicConnectModel productModel = AcademicConnectModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.allEvent.setList(list: list, isClear: false, isNotify: false);
      provider.isAcademicConnectFirstTimeLoading.set(value: false, isNotify: true);
      provider.isAcademicConnectLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final AcademicConnect Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final AcademicConnect Length in Provider:${provider.allAcademicConnectLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getAcademicConnectPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.allEvent.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreAcademicConnect.set(value: true, isNotify: false);
      provider.lastCourseDocument.set(value: null, isNotify: false);
      provider.isAcademicConnectFirstTimeLoading.set(value: false, isNotify: false);
      provider.isAcademicConnectLoading.set(value: false, isNotify: true);
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

  Future<void> addAcademicConnectToFirebase({required AcademicConnectModel academicConnectModel, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$academicConnectModel'");

    try {
      await academicConnectRepository.addAcademicConnectRepo(academicConnectModel);
      if (isAdInProvider) {
        academicConnectProvider.addCourseModelInCourseList(academicConnectModel);
      } else {
        String title = "Academic Connect updated";
        String description = "'${academicConnectModel.title}' Academic connect has been added";
        String image = academicConnectModel.imageUrl;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: academicConnectModel.id,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': academicConnectModel.id,
            'title': title,
            'description': description,
            'type': NotificationTypes.event,
            'imageurl': image,
          },
        );
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Course to Firebase in Course Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

// Future<List<CourseModel>> getUserAcademicConnectList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
//   String tag = MyUtils.getNewId();
//   MyPrint.printOnConsole("CourseController().getUserAcademicConnectList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
//
//   EventProvider provider = courseProvider;
//
//   if (!isRefresh) {
//     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
//     return provider.events.getList(isNewInstance: true);
//   }
//
//   if (provider.isMyAcademicConnectFirstTimeLoading.get()) {
//     MyPrint.printOnConsole("Returning from CourseController().getUserAcademicConnectList() because myAcademicConnect already fetching", tag: tag);
//     return provider.events.getList(isNewInstance: true);
//   }
//
//   MyPrint.printOnConsole("Refresh", tag: tag);
//   provider.isMyAcademicConnectFirstTimeLoading.set(value: true, isNotify: false);
//   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
//
//   try {
//     List<CourseModel> list = await courseRepository.getAcademicConnectListFromIdsList(courseIds: myCourseIds);
//
//     provider.events.setList(list: list, isClear: true, isNotify: false);
//     provider.isMyAcademicConnectFirstTimeLoading.set(value: false, isNotify: true);
//     MyPrint.printOnConsole("Final AcademicConnect Length From Firestore:${list.length}", tag: tag);
//     MyPrint.printOnConsole("Final AcademicConnect Length in Provider:${provider.myAcademicConnectLength}", tag: tag);
//     return list;
//   } catch (e, s) {
//     MyPrint.printOnConsole("Error in CourseController().getUserAcademicConnectList():$e", tag: tag);
//     MyPrint.printOnConsole(s, tag: tag);
//     provider.events.setList(list: [], isClear: true, isNotify: false);
//     provider.isMyAcademicConnectFirstTimeLoading.set(value: false, isNotify: false);
//     return [];
//   }
// }
}
