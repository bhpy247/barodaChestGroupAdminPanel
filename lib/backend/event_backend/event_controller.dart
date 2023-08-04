
import 'package:baroda_chest_group_admin/models/event/data_model/event_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/course/data_model/course_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'event_provider.dart';
import 'event_repository.dart';

class EventController {
  late EventProvider eventProvider;
  late EventRepository eventRepository;

  EventController({required this.eventProvider, EventRepository? repository}) {
    eventRepository = repository ?? EventRepository();
  }

  Future<void> getAllCourseList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<EventModel> coursesList = [];
    coursesList = await eventRepository.getEventListRepo();
    if (coursesList.isNotEmpty) {
      eventProvider.allEvent.setList(list: coursesList);
    }
  }

  Future<List<EventModel>> getCoursesPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getCoursesPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    EventProvider provider = eventProvider;

    if (!isRefresh && isFromCache && provider.allCoursesLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.allEvent.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreCourses.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastCourseDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isCoursesFirstTimeLoading.set(value: true, isNotify: false);
      provider.isCoursesLoading.set(value: false, isNotify: false);
      provider.allEvent.setList(list: <EventModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreCourses.get()) {
        MyPrint.printOnConsole('No More Courses', tag: tag);
        return provider.allEvent.getList(isNewInstance: true);
      }
      if (provider.isCoursesLoading.get()) return provider.allEvent.getList(isNewInstance: true);

      provider.isCoursesLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.eventCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastCourseDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Courses:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreCourses.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastCourseDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<EventModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          EventModel productModel = EventModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.allEvent.setList(list: list, isClear: false, isNotify: false);
      provider.isCoursesFirstTimeLoading.set(value: false, isNotify: true);
      provider.isCoursesLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Courses Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Courses Length in Provider:${provider.allCoursesLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getCoursesPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.allEvent.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreCourses.set(value: true, isNotify: false);
      provider.lastCourseDocument.set(value: null, isNotify: false);
      provider.isCoursesFirstTimeLoading.set(value: false, isNotify: false);
      provider.isCoursesLoading.set(value: false, isNotify: true);
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

  Future<void> addEventToFirebase({required EventModel eventModel, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$eventModel'");

    try {
      await eventRepository.addEventRepo(eventModel);
      if (isAdInProvider) {
        eventProvider.addCourseModelInCourseList(eventModel);
      } else {
        String title = "Event updated";
        String description = "'${eventModel.title}' Event has been added";
        String image = eventModel.imageUrl;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: eventModel.id,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': eventModel.id,
            'title': title,
            'description': description,
            'type': NotificationTypes.editCourse,
            'imageurl': image,
          },
        );
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in Add Course to Firebase in Course Controller $e');
      MyPrint.printOnConsole(s);
    }
  }

  // Future<List<CourseModel>> getUserCoursesList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
  //   String tag = MyUtils.getNewId();
  //   MyPrint.printOnConsole("CourseController().getUserCoursesList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
  //
  //   EventProvider provider = courseProvider;
  //
  //   if (!isRefresh) {
  //     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   if (provider.isMyCoursesFirstTimeLoading.get()) {
  //     MyPrint.printOnConsole("Returning from CourseController().getUserCoursesList() because myCourses already fetching", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   MyPrint.printOnConsole("Refresh", tag: tag);
  //   provider.isMyCoursesFirstTimeLoading.set(value: true, isNotify: false);
  //   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
  //
  //   try {
  //     List<CourseModel> list = await courseRepository.getCoursesListFromIdsList(courseIds: myCourseIds);
  //
  //     provider.events.setList(list: list, isClear: true, isNotify: false);
  //     provider.isMyCoursesFirstTimeLoading.set(value: false, isNotify: true);
  //     MyPrint.printOnConsole("Final Courses Length From Firestore:${list.length}", tag: tag);
  //     MyPrint.printOnConsole("Final Courses Length in Provider:${provider.myCoursesLength}", tag: tag);
  //     return list;
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in CourseController().getUserCoursesList():$e", tag: tag);
  //     MyPrint.printOnConsole(s, tag: tag);
  //     provider.events.setList(list: [], isClear: true, isNotify: false);
  //     provider.isMyCoursesFirstTimeLoading.set(value: false, isNotify: false);
  //     return [];
  //   }
  // }
}
