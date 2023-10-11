import 'package:baroda_chest_group_admin/backend/users_backend/user_provider.dart';
import 'package:baroda_chest_group_admin/backend/users_backend/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/common/data_model/new_document_data_model.dart';
import '../../models/event/data_model/event_model.dart';
import '../../models/user/data_model/user_course_enrollment_model.dart';
import '../../models/user/data_model/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';
import '../event_backend/event_provider.dart';
import '../notification/notification_controller.dart';

class UserController {
  late UserProvider userProvider;
  late UserRepository userRepository;

  UserController({required UserProvider? userProvider, UserRepository? repository}) {
    this.userProvider = userProvider ?? UserProvider();
    userRepository = repository ?? UserRepository();
  }

  Future<void> getAllUsersFromFirebase({bool isRefresh = true, bool isNotify = true}) async {
    try {
      MyPrint.printOnConsole("In Side The Method");

      if (!isRefresh && userProvider.usersListLength > 0) {
        MyPrint.printOnConsole("Returning Cached Data");
        userProvider.usersList;
      }

      if (isRefresh) {
        MyPrint.printOnConsole("Refresh");
        userProvider.setHasMoreUsers = true; // flag for more products available or not
        userProvider.setLastDocument = null; // flag for last document from where next 10 records to be fetched
        userProvider.setIsUsersLoading(false, isNotify: isNotify);
        userProvider.setUsersList([], isNotify: isNotify);
      }

      if (!userProvider.getHasMoreUsers) {
        MyPrint.printOnConsole('No More Users');
        return;
      }
      if (userProvider.getIsUsersLoading) return;

      userProvider.setIsUsersLoading(true, isNotify: isNotify);

      Query<Map<String, dynamic>> query =
      FirebaseNodes.usersCollectionReference.limit(5).orderBy("createdTime", descending: true);

      //For Last Document
      DocumentSnapshot<Map<String, dynamic>>? snapshot = userProvider.getLastDocument;
      if (snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null");
        query = query.startAfterDocument(snapshot);
      } else {
        MyPrint.printOnConsole("LastDocument null");
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Admin Users:${querySnapshot.docs.length}");

      if (querySnapshot.docs.length < 5) userProvider.setHasMoreUsers = false;

      if (querySnapshot.docs.isNotEmpty) userProvider.setLastDocument = querySnapshot.docs[querySnapshot.docs.length - 1];

      List<UserModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if ((documentSnapshot.data() ?? {}).isNotEmpty) {
          UserModel userModel = UserModel.fromMap(documentSnapshot.data()!);
          list.add(userModel);
        }
      }
      userProvider.addAllUsersList(list, isNotify: false);
      userProvider.setIsUsersLoading(false);
      MyPrint.printOnConsole("Final User Length From Firestore:${list.length}");
      MyPrint.printOnConsole("Final User Length in Provider:${userProvider.usersListLength}");
    } catch (e, s) {
      MyPrint.printOnConsole("Error in get User List form Firebase in user Controller $e");
      MyPrint.printOnConsole(s);
    }
  }

  Future<UserModel> getUserFromUserIdFirebase({ required String userId, bool isRefresh = true, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();

    try {
      MyPrint.printOnConsole("UserController().getUserFromUserIdFirebase called with getEventOnBasisOfId:$userId", tag: tag);


      MyPrint.printOnConsole("Refresh", tag: tag);

      MyFirestoreCollectionReference docs = FirestoreController.collectionReference(collectionName: FirebaseNodes.usersCollection);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = await docs.doc(userId).get();
      MyPrint.printOnConsole("Documents Length in Firestore for events:${snapshot.id}", tag: tag);
      UserModel userModel = UserModel();

      if (snapshot.exists) {
        userModel = UserModel.fromMap(snapshot.data()!);
      }
      MyPrint.printOnConsole("Final events Length From Firestore:${userModel.id}", tag: tag);
      return userModel;
    }
    catch (e, s) {
      MyPrint.printOnConsole("Error in UserController().getUserFromUserIdFirebase():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return UserModel();
    }
  }

    Future<bool> assignCourse({required UserModel userModel, required String courseId, required int validityDays, String courseName = "", String courseImage = ""}) async {
      String tag = MyUtils.getNewId();
      MyPrint.printOnConsole("UserController().assignCourse() called for CourseId:$courseId, validityDays:$validityDays", tag: tag);

      if (userModel.id.isEmpty) {
        MyPrint.printOnConsole("Returning from UserController().assignCourse() because userId is empty", tag: tag);
        return false;
      }

      if (courseId.isEmpty) {
        MyPrint.printOnConsole("Returning from UserController().assignCourse() because courseId is empty", tag: tag);
        return false;
      }

      if (validityDays <= 0) {
        MyPrint.printOnConsole("Returning from UserController().assignCourse() because validityDays are <= 0", tag: tag);
        return false;
      }

      UserCourseEnrollmentModel userCourseEnrollmentModel = UserCourseEnrollmentModel.fromMap(userModel.myCoursesData[courseId]?.toMap() ?? {});
      userCourseEnrollmentModel.courseId = courseId;

      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      MyPrint.printOnConsole("New Timestamp:${newDocumentDataModel.timestamp.toDate().toString()}", tag: tag);

      bool isPlanActive = false;

      if (userCourseEnrollmentModel.activatedDate != null &&
          userCourseEnrollmentModel.expiryDate != null &&
          userCourseEnrollmentModel.activatedDate!.toDate().isBefore(userCourseEnrollmentModel.expiryDate!.toDate()) &&
          newDocumentDataModel.timestamp.toDate().isBefore(userCourseEnrollmentModel.expiryDate!.toDate())) {
        isPlanActive = true;
      }
      MyPrint.printOnConsole("isPlanActive:$isPlanActive", tag: tag);

      if (isPlanActive) {
        userCourseEnrollmentModel.validityInDays += validityDays;
        userCourseEnrollmentModel.expiryDate =
            Timestamp.fromDate(userCourseEnrollmentModel.activatedDate!.toDate().add(Duration(days: userCourseEnrollmentModel.validityInDays)));
      } else {
        userCourseEnrollmentModel.activatedDate = newDocumentDataModel.timestamp;
        userCourseEnrollmentModel.validityInDays = validityDays;
        userCourseEnrollmentModel.expiryDate = Timestamp.fromDate(newDocumentDataModel.timestamp.toDate().add(Duration(days: validityDays)));
      }
      MyPrint.printOnConsole("new userCourseEnrollmentModel:$userCourseEnrollmentModel", tag: tag);

      bool isUpdated = await userRepository.updateUserCourseEnrollmentData(userId: userModel.id, enrollmentModel: userCourseEnrollmentModel);
      MyPrint.printOnConsole("isUpdated:$isUpdated", tag: tag);

      if (isUpdated) {
        UserCourseEnrollmentModel? enrollmentModel = userModel.myCoursesData[courseId];
        if (enrollmentModel != null) {
          enrollmentModel.activatedDate = userCourseEnrollmentModel.activatedDate;
          enrollmentModel.validityInDays = userCourseEnrollmentModel.validityInDays;
          enrollmentModel.expiryDate = userCourseEnrollmentModel.expiryDate;

          String title = isPlanActive ? "Course Validity Extended" : "New Course Assigned";
          String description = isPlanActive
              ? "${courseName.isNotEmpty ? "'$courseName' " : ""}Course validity has been extended by Admin"
              : "${courseName.isNotEmpty ? "'$courseName' " : ""}Course has been assigned to you";
          String image = courseImage;

          NotificationController.sendNotificationMessage2(
            title: title,
            description: description,
            image: image,
            topic: userModel.id,
            collapseKey: courseId,
            tag: courseId,
            data: <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'objectid': courseId,
              'title': title,
              'description': description,
              'type': isPlanActive ? NotificationTypes.courseValidityExtended : NotificationTypes.courseAssigned,
              'imageurl': image,
            },
          );
        } else {
          userModel.myCoursesData[courseId] = userCourseEnrollmentModel;
        }
        MyPrint.printOnConsole("final userCourseEnrollmentModel:${userModel.myCoursesData[courseId]}", tag: tag);
      }

      return isUpdated;
    }

    Future<bool> expireUserCourse({required UserModel userModel, required String courseId, String courseName = "", String courseImage = ""}) async {
      String tag = MyUtils.getNewId();
      MyPrint.printOnConsole("UserController().expireUserCourse() called for CourseId:$courseId", tag: tag);

      UserCourseEnrollmentModel userCourseEnrollmentModel = UserCourseEnrollmentModel.fromMap(userModel.myCoursesData[courseId]?.toMap() ?? {});
      userCourseEnrollmentModel.courseId = courseId;

      userCourseEnrollmentModel.activatedDate = null;
      userCourseEnrollmentModel.validityInDays = 0;
      userCourseEnrollmentModel.expiryDate = null;

      bool isUpdated = await userRepository.updateUserCourseEnrollmentData(userId: userModel.id, enrollmentModel: userCourseEnrollmentModel);
      MyPrint.printOnConsole("isUpdated:$isUpdated", tag: tag);

      if (isUpdated) {
        UserCourseEnrollmentModel? enrollmentModel = userModel.myCoursesData[courseId];
        if (enrollmentModel != null) {
          enrollmentModel.activatedDate = userCourseEnrollmentModel.activatedDate;
          enrollmentModel.validityInDays = userCourseEnrollmentModel.validityInDays;
          enrollmentModel.expiryDate = userCourseEnrollmentModel.expiryDate;
        } else {
          userModel.myCoursesData[courseId] = userCourseEnrollmentModel;
        }
        MyPrint.printOnConsole("final userCourseEnrollmentModel:${userModel.myCoursesData[courseId]}", tag: tag);

        String title = "Course Expired";
        String description = "${courseName.isNotEmpty ? "$courseName " : ""}Course has been expired by Admin";
        String image = courseImage;

        NotificationController.sendNotificationMessage2(
          title: title,
          description: description,
          image: image,
          topic: userModel.id,
          collapseKey: courseId,
          tag: courseId,
          data: <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'objectid': courseId,
            'title': title,
            'description': description,
            'type': NotificationTypes.courseExpired,
            'imageurl': image,
          },
        );
      }

      return isUpdated;
    }

    Future<bool> unAssignCourse({required UserModel userModel, required String courseId}) async {
      String tag = MyUtils.getNewId();
      MyPrint.printOnConsole("UserController().unAssignCourse() called for CourseId:$courseId", tag: tag);

      bool isUpdated = await userRepository.terminateUserCourseEnrollmentData(userId: userModel.id, courseId: courseId);
      MyPrint.printOnConsole("isUpdated:$isUpdated", tag: tag);

      if (isUpdated) {
        userModel.myCoursesData.remove(courseId);
        MyPrint.printOnConsole("final userCourseEnrollmentModel:${userModel.myCoursesData[courseId]}", tag: tag);
      }

      return isUpdated;
    }

/*Future<void> EnableDisableUserInFirebase({required Map<String,dynamic> editableData,required String id,required int listIndex}) async {

    try{

      await FirebaseNodes.userDocumentReference(userId: id)
          .update(editableData).then((value) {
        MyPrint.printOnConsole("user data: ${editableData["adminEnabled"]}");
        userProvider.updateEnableDisableOfList(editableData["adminEnabled"] , listIndex);
      });
    }catch(e,s){
      MyPrint.printOnConsole("Error in Enable Disable User in firebase in User Controller $e");
      MyPrint.printOnConsole(s);
    }
  }*/
  }
