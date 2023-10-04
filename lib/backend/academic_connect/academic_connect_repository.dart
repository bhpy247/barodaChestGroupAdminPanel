

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/academic_connect/data_model/academic_connect_model.dart';
import '../../models/course/data_model/course_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class AcademicConnectRepository {

  Future<List<AcademicConnectModel>> getAcademicConnectListRepo() async {
    List<AcademicConnectModel> courseList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.eventCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            courseList.add(AcademicConnectModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Course Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getCoursesListRepo in CourseRepository $e');
      MyPrint.printOnConsole(s);
    }

    return courseList;
  }

  Future<void> addAcademicConnectRepo(AcademicConnectModel academicConnectModel) async {
    await FirebaseNodes.academicConnectDocumentReference(academicConnectId: academicConnectModel.id).set(academicConnectModel.toMap());
  }

  Future<List<CourseModel>> getCoursesListFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseRepository().getCoursesListFromIdsList called with courseIds:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.academicConnectCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for User Courses:${docs.length}", tag: tag);

      List<CourseModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          CourseModel productModel = CourseModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final Courses Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CourseRepository().getCoursesListFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}