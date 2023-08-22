
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/committee_member_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../notification/notification_controller.dart';
import 'committee_member_provider.dart';
import 'committee_member_repository.dart';

class CommitteeMemberController {
  late CommitteeMemberProvider committeeMemberProvider;
  late CommitteeMemberRepository committeeMemberRepository;

  CommitteeMemberController({required this.committeeMemberProvider, CommitteeMemberRepository? repository}) {
    committeeMemberRepository = repository ?? CommitteeMemberRepository();
  }

  Future<void> getAllBrochureList() async {
    MyPrint.printOnConsole("CourseController().getAllCourseList() called");

    List<CommitteeMemberModel> committeeMemberList = [];
    committeeMemberList = await committeeMemberRepository.getCommitteeMemberListRepo();
    if (committeeMemberList.isNotEmpty) {
      committeeMemberProvider.committeeMemberList.setList(list: committeeMemberList);
    }
  }

  Future<List<CommitteeMemberModel>> getCommitteeMemberPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getBrochurePaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    CommitteeMemberProvider provider = committeeMemberProvider;

    if (!isRefresh && isFromCache && provider.allCommitteeMemberLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.committeeMemberList.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreCommitteeMember.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastCommitteeMemberDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isCommitteeMemberFirstTimeLoading.set(value: true, isNotify: false);
      provider.isCommitteeMemberLoading.set(value: false, isNotify: false);
      provider.committeeMemberList.setList(list: <CommitteeMemberModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreCommitteeMember.get()) {
        MyPrint.printOnConsole('No More Brochure', tag: tag);
        return provider.committeeMemberList.getList(isNewInstance: true);
      }
      if (provider.isCommitteeMemberLoading.get()) return provider.committeeMemberList.getList(isNewInstance: true);

      provider.isCommitteeMemberLoading.set(value: true, isNotify: isNotify);

      MyFirestoreQuery query = FirebaseNodes.committeeMemberCollectionReference.limit(AppConstants.coursesDocumentLimitForPagination).orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastCommitteeMemberDocument.get();
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      MyFirestoreQuerySnapshot querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Brochure:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreCommitteeMember.set(value: false, isNotify: false);

      if (querySnapshot.docs.isNotEmpty) provider.lastCommitteeMemberDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<CommitteeMemberModel> list = [];
      for (MyFirestoreQueryDocumentSnapshot documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.data().isNotEmpty) {
          CommitteeMemberModel productModel = CommitteeMemberModel.fromMap(documentSnapshot.data());
          list.add(productModel);
        }
      }
      provider.committeeMemberList.setList(list: list, isClear: false, isNotify: false);
      provider.isCommitteeMemberFirstTimeLoading.set(value: false, isNotify: true);
      provider.isCommitteeMemberLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Brochure Length in Provider:${provider.allCommitteeMemberLength}", tag: tag);
      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in CourseController().getBrochurePaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.committeeMemberList.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreCommitteeMember.set(value: true, isNotify: false);
      provider.lastCommitteeMemberDocument.set(value: null, isNotify: false);
      provider.isCommitteeMemberFirstTimeLoading.set(value: false, isNotify: false);
      provider.isCommitteeMemberLoading.set(value: false, isNotify: true);
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

  Future<void> addCommitteeMemberToFirebase({required CommitteeMemberModel committeeMemberModel, bool isAdInProvider = false}) async {
    MyPrint.printOnConsole("CourseController().addCourseToFirebase() called with courseModel:'$committeeMemberModel'");

    try {
      await committeeMemberRepository.addCommitteeMemberRepo(committeeMemberModel);
      if (isAdInProvider) {
        committeeMemberProvider.addCommitteeMemberModelInCourseList(committeeMemberModel);
      } else {
        String title = "Case of month updated";
        String description = "'${committeeMemberModel.name}' Case of month has been added";
        String image = committeeMemberModel.profileUrl;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: committeeMemberModel.id,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': committeeMemberModel.id,
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
