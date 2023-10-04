

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/contact_us_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'contact_us_provider.dart';
import 'contact_us_repository.dart';

class ContactUsController {
  late ContactUsProvider contactUsProvider;
  late ContactUsRepository contactUsRepository;

  ContactUsController({required this.contactUsProvider, ContactUsRepository? repository}) {
    contactUsRepository = repository ?? ContactUsRepository();
  }

  Future<void> getAllContactUsList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<ContactUsModel> contactUsList = [];
    contactUsList = await contactUsRepository.getContactUsListRepo();
    if (contactUsList.isNotEmpty) {
      contactUsProvider.contactUsList.setList(list: contactUsList);
    }
  }

  Future<List<ContactUsModel>> getContactUsPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getContactUsPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    ContactUsProvider provider = contactUsProvider;

    if (!isRefresh && isFromCache && provider.allContactUsLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.contactUsList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreContactUs.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastContactUsDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isContactUsFirstTimeLoading.set(value: true, isNotify: false);
      provider.isContactUsLoading.set(value: false, isNotify: false);
      provider.contactUsList.setList(list: <ContactUsModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreContactUs.get()) {
        MyPrint.printOnConsole('No More ContactUs', tag: tag);
        return provider.contactUsList.getList(isNewInstance: true);
      }
      if (provider.isContactUsLoading.get()) return provider.contactUsList.getList(isNewInstance: true);

      provider.isContactUsLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.contactUsCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastContactUsDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for ContactUs:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreContactUs.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastContactUsDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<ContactUsModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          ContactUsModel productModel = ContactUsModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.contactUsList.setList(list: list, isClear: false, isNotify: false);
      provider.isContactUsFirstTimeLoading.set(value: false, isNotify: true);
      provider.isContactUsLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final ContactUs Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final ContactUs Length in Provider:${provider.allContactUsLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getContactUsPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.contactUsList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreContactUs.set(value: true, isNotify: false);
      provider.lastContactUsDocument.set(value: null, isNotify: false);
      provider.isContactUsFirstTimeLoading.set(value: false, isNotify: false);
      provider.isContactUsLoading.set(value: false, isNotify: true);
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

  Future<void> addContactUsToFirebase({required ContactUsModel contactUs, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$contactUs'");

    try {
      await contactUsRepository.addContactUsRepo(contactUs);
      if (isAdInProvider) {
        contactUsProvider.addContactUsModelInCourseList(contactUs);
      } else {
        String title = "Case of month updated";
        String description = "'${contactUs.name}' Case of month has been added";
        String image = contactUs.email;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: contactUs.id,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': contactUs.id,
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

  // Future<List<CourseModel>> getUserContactUsList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
  //   String tag = MyUtils.getNewId();
  //   MyPrint.printOnConsole("CourseController().getUserContactUsList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
  //
  //   EventProvider provider = courseProvider;
  //
  //   if (!isRefresh) {
  //     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   if (provider.isMyContactUsFirstTimeLoading.get()) {
  //     MyPrint.printOnConsole("Returning from CourseController().getUserContactUsList() because myContactUs already fetching", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   MyPrint.printOnConsole("Refresh", tag: tag);
  //   provider.isMyContactUsFirstTimeLoading.set(value: true, isNotify: false);
  //   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
  //
  //   try {
  //     List<CourseModel> list = await courseRepository.getContactUsListFromIdsList(courseIds: myCourseIds);
  //
  //     provider.events.setList(list: list, isClear: true, isNotify: false);
  //     provider.isMyContactUsFirstTimeLoading.set(value: false, isNotify: true);
  //     MyPrint.printOnConsole("Final ContactUs Length From Firestore:${list.length}", tag: tag);
  //     MyPrint.printOnConsole("Final ContactUs Length in Provider:${provider.myContactUsLength}", tag: tag);
  //     return list;
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in CourseController().getUserContactUsList():$e", tag: tag);
  //     MyPrint.printOnConsole(s, tag: tag);
  //     provider.events.setList(list: [], isClear: true, isNotify: false);
  //     provider.isMyContactUsFirstTimeLoading.set(value: false, isNotify: false);
  //     return [];
  //   }
  // }
}
