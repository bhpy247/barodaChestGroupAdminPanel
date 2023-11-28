
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'brochure_provider.dart';
import 'brochure_repository.dart';

class BrochureController {
  late BrochureProvider brochureProvider;
  late BrochureRepository brochureRepository;

  BrochureController({required this.brochureProvider, BrochureRepository? repository}) {
    brochureRepository = repository ?? BrochureRepository();
  }

  Future<void> getAllBrochureList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<BrochureModel> brochureList = [];
    brochureList = await brochureRepository.getBrochureListRepo();
    if (brochureList.isNotEmpty) {
      brochureProvider.brochureList.setList(list: brochureList);
    }
  }

  Future<List<BrochureModel>> getBrochurePaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getBrochurePaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    BrochureProvider provider = brochureProvider;

    if (!isRefresh && isFromCache && provider.alBrochureLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.brochureList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreBrochure.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastBrochureDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isBrochureFirstTimeLoading.set(value: true, isNotify: false);
      provider.isBrochureLoading.set(value: false, isNotify: false);
      provider.brochureList.setList(list: <BrochureModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreBrochure.get()) {
        MyPrint.printOnConsole('No More Brochure', tag: tag);
        return provider.brochureList.getList(isNewInstance: true);
      }
      if (provider.isBrochureLoading.get()) return provider.brochureList.getList(isNewInstance: true);

      provider.isBrochureLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.brochureCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastBrochureDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Brochure:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreBrochure.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastBrochureDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<BrochureModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          BrochureModel productModel = BrochureModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.brochureList.setList(list: list, isClear: false, isNotify: false);
      provider.isBrochureFirstTimeLoading.set(value: false, isNotify: true);
      provider.isBrochureLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Brochure Length in Provider:${provider.alBrochureLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getBrochurePaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.brochureList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreBrochure.set(value: true, isNotify: false);
      provider.lastBrochureDocument.set(value: null, isNotify: false);
      provider.isBrochureFirstTimeLoading.set(value: false, isNotify: false);
      provider.isBrochureLoading.set(value: false, isNotify: true);
      return [];
    }
  }

  Future<void> addBrochureToFirebase({required BrochureModel caseOfMonth, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$caseOfMonth'");

    try {
      await brochureRepository.addBrochureRepo(caseOfMonth);
      if (isAdInProvider) {
        brochureProvider.addBrochureModelInCourseList(caseOfMonth);
      } else {
        String title = "Case of month updated";
        String description = "'${caseOfMonth.brochureName}' Case of month has been added";
        String image = caseOfMonth.brochureName;

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
}
