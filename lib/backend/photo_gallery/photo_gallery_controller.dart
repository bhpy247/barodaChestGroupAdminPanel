
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/gallery_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'photo_gallery_provider.dart';
import 'photo_gallery_repository.dart';

class PhotoGalleryController {
  late PhotoGalleryProvider photoGalleryProvider;
  late PhotoGalleryRepository photoGalleryRepository;

  PhotoGalleryController({required this.photoGalleryProvider, PhotoGalleryRepository? repository}) {
    photoGalleryRepository = repository ?? PhotoGalleryRepository();
  }

  Future<void> getAllBrochureList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<GalleryModel> photoGalleryList = [];
    photoGalleryList = await photoGalleryRepository.getPhotoGalleryListRepo();
    if (photoGalleryList.isNotEmpty) {
      photoGalleryProvider.photoGalleryModelList.setList(list: photoGalleryList);
    }
  }

  Future<List<GalleryModel>> getPhotoGalleryPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getBrochurePaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    PhotoGalleryProvider provider = photoGalleryProvider;

    if (!isRefresh && isFromCache && provider.photoGalleryModelLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.photoGalleryModelList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMorePhotoGallery.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastPhotoGalleryDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isMyPhotoGalleryFirstTimeLoading.set(value: true, isNotify: false);
      provider.isPhotoGalleryLoading.set(value: false, isNotify: false);
      provider.photoGalleryModelList.setList(list: <GalleryModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMorePhotoGallery.get()) {
        MyPrint.printOnConsole('No More Brochure', tag: tag);
        return provider.photoGalleryModelList.getList(isNewInstance: true);
      }
      if (provider.isPhotoGalleryLoading.get()) return provider.photoGalleryModelList.getList(isNewInstance: true);

      provider.isPhotoGalleryLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.galleryCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastPhotoGalleryDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Brochure:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMorePhotoGallery.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastPhotoGalleryDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<GalleryModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          GalleryModel productModel = GalleryModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.photoGalleryModelList.setList(list: list, isClear: false, isNotify: false);
      provider.isMyPhotoGalleryFirstTimeLoading.set(value: false, isNotify: true);
      provider.isPhotoGalleryLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Brochure Length in Provider:${provider.photoGalleryModelLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getBrochurePaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.photoGalleryModelList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMorePhotoGallery.set(value: true, isNotify: false);
      provider.lastPhotoGalleryDocument.set(value: null, isNotify: false);
      provider.isMyPhotoGalleryFirstTimeLoading.set(value: false, isNotify: false);
      provider.isPhotoGalleryLoading.set(value: false, isNotify: true);
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

  Future<void> addBrochureToFirebase({required GalleryModel caseOfMonth, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$caseOfMonth'");

    try {
      await photoGalleryRepository.addBrochureRepo(caseOfMonth);
      if (isAdInProvider) {
        photoGalleryProvider.addGalleryModelInCourseList(caseOfMonth);
      } else {
        String title = "Case of month updated";
        String description = "'${caseOfMonth.description}' Case of month has been added";
        String image = caseOfMonth.eventName;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: caseOfMonth.id,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': caseOfMonth.id,
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

  // Future<List<CourseModel>> getUserBrochureList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
  //   String tag = MyUtils.getNewId();
  //   MyPrint.printOnConsole("CourseController().getUserBrochureList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);
  //
  //   EventProvider provider = courseProvider;
  //
  //   if (!isRefresh) {
  //     MyPrint.printOnConsole("Returning Cached Data", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   if (provider.isMyBrochureFirstTimeLoading.get()) {
  //     MyPrint.printOnConsole("Returning from CourseController().getUserBrochureList() because myBrochure already fetching", tag: tag);
  //     return provider.events.getList(isNewInstance: true);
  //   }
  //
  //   MyPrint.printOnConsole("Refresh", tag: tag);
  //   provider.isMyBrochureFirstTimeLoading.set(value: true, isNotify: false);
  //   provider.events.setList(list: <CourseModel>[], isNotify: isNotify);
  //
  //   try {
  //     List<CourseModel> list = await courseRepository.getBrochureListFromIdsList(courseIds: myCourseIds);
  //
  //     provider.events.setList(list: list, isClear: true, isNotify: false);
  //     provider.isMyBrochureFirstTimeLoading.set(value: false, isNotify: true);
  //     MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);
  //     MyPrint.printOnConsole("Final Brochure Length in Provider:${provider.myBrochureLength}", tag: tag);
  //     return list;
  //   } catch (e, s) {
  //     MyPrint.printOnConsole("Error in CourseController().getUserBrochureList():$e", tag: tag);
  //     MyPrint.printOnConsole(s, tag: tag);
  //     provider.events.setList(list: [], isClear: true, isNotify: false);
  //     provider.isMyBrochureFirstTimeLoading.set(value: false, isNotify: false);
  //     return [];
  //   }
  // }
}
