
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

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
        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          // image: image,
          topic: memberModel.id,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': memberModel.id,
            'title': title,
            'description': description,
            'type': NotificationTypes.editCourse,
          },
        );
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
}
