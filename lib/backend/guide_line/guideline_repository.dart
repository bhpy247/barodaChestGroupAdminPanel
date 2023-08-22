
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/guideline_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class GuidelineRepository {

  Future<List<GuidelineModel>> getGuidelineListRepo() async {
    List<GuidelineModel> guidelineList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.guidelineCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            guidelineList.add(GuidelineModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Guideline Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getGuidelineRepo in GuidelineRepository $e');
      MyPrint.printOnConsole(s);
    }

    return guidelineList;
  }

  Future<void> addGuidelineRepo(GuidelineModel caseOfMonthModel) async {
    await FirebaseNodes.guidelineDocumentReference(userId: caseOfMonthModel.id).set(caseOfMonthModel.toMap());
  }

  Future<List<GuidelineModel>> getGuidelineFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("GuidelineRepository().getGuidelineFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.guidelineCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<GuidelineModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          GuidelineModel productModel = GuidelineModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final Guideline Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in GuidelineRepository().getGuidelineFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}