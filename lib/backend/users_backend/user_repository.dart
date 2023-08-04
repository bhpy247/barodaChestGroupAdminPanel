import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/user/data_model/user_course_enrollment_model.dart';
import '../../models/user/data_model/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class UserRepository {
  Future<UserModel?> getUserModelFromId({required String userId}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().getUserModelFromId() called with userId:'$userId'", tag: tag);

    if(userId.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().getUserModelFromId() because userId is empty", tag: tag);
      return null;
    }

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.userDocumentReference(userId: userId).get();
      MyPrint.printOnConsole("snapshot.exists:'${snapshot.exists}'", tag: tag);
      MyPrint.printOnConsole("snapshot.data():'${snapshot.data()}'", tag: tag);

      if(snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
        return UserModel.fromMap(snapshot.data()!);
      }
      else {
        return null;
      }
    }
    catch(e,s) {
      MyPrint.printOnConsole("Error in UserRepository().getUserModelFromId():'$e'", tag: tag);
      MyPrint.printOnConsole(s ,tag: tag);
      return null;
    }
  }

  Future<bool> updateUserCourseEnrollmentData({required String userId, required UserCourseEnrollmentModel enrollmentModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().updateUserCourseEnrollmentData() called with userId:'$userId', enrollmentModel:'$enrollmentModel'", tag: tag);

    if(userId.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().updateUserProfileData() because userId is empty", tag: tag);
      return false;
    }

    if(enrollmentModel.courseId.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().updateUserProfileData() because courseId is empty", tag: tag);
      return false;
    }

    bool isUpdated = false;

    try {
      await FirebaseNodes.userDocumentReference(userId: userId).update({
        "myCoursesData.${enrollmentModel.courseId}.courseId" : enrollmentModel.courseId,
        "myCoursesData.${enrollmentModel.courseId}.activatedDate" : enrollmentModel.activatedDate,
        "myCoursesData.${enrollmentModel.courseId}.validityInDays" : enrollmentModel.validityInDays,
        "myCoursesData.${enrollmentModel.courseId}.expiryDate" : enrollmentModel.expiryDate,
      });
      isUpdated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in Firestore in UserRepository().updateUserCourseEnrollmentData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }

  Future<bool> terminateUserCourseEnrollmentData({required String userId, required String courseId}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserRepository().terminateUserCourseEnrollmentData() called with userId:'$userId', courseId:'$courseId'", tag: tag);

    if(userId.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().updateUserProfileData() because userId is empty", tag: tag);
      return false;
    }

    if(courseId.isEmpty) {
      MyPrint.printOnConsole("Returning from UserRepository().updateUserProfileData() because courseId is empty", tag: tag);
      return false;
    }

    bool isUpdated = false;

    try {
      await FirebaseNodes.userDocumentReference(userId: userId).update({
        "myCoursesData.$courseId" : FieldValue.delete(),
      });
      isUpdated = true;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in Firestore in UserRepository().terminateUserCourseEnrollmentData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }
}