
import 'package:baroda_chest_group_admin/models/event/data_model/event_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/course/data_model/course_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class EventRepository {

  Future<List<EventModel>> getEventListRepo() async {
    List<EventModel> courseList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.eventCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            courseList.add(EventModel.fromMap(queryDocumentSnapshot.data()));
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

  Future<void> addEventRepo(EventModel eventModel) async {
    await FirebaseNodes.eventsDocumentReference(courseId: eventModel.id).set(eventModel.toMap());
  }

  Future<List<CourseModel>> getCoursesListFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseRepository().getCoursesListFromIdsList called with courseIds:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.eventCollectionReference,
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