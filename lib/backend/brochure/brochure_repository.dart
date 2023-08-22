
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class BrochureRepository {

  Future<List<BrochureModel>> getBrochureListRepo() async {
    List<BrochureModel> brochureList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.brochureCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            brochureList.add(BrochureModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Brochure Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getBrochureRepo in BrochureRepository $e');
      MyPrint.printOnConsole(s);
    }

    return brochureList;
  }

  Future<void> addBrochureRepo(BrochureModel caseOfMonthModel) async {
    await FirebaseNodes.brochureDocumentReference(courseId: caseOfMonthModel.id).set(caseOfMonthModel.toMap());
  }

  Future<List<BrochureModel>> getBrochureFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("BrochureRepository().getBrochureFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.caseOfMonthCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<BrochureModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          BrochureModel productModel = BrochureModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in BrochureRepository().getBrochureFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}