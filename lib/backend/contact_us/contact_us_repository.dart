
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/profile/data_model/contact_us_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class ContactUsRepository {

  Future<List<ContactUsModel>> getContactUsListRepo() async {
    List<ContactUsModel> contactUsList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.contactUsCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            contactUsList.add(ContactUsModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("ContactUs Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getContactUsRepo in ContactUsRepository $e');
      MyPrint.printOnConsole(s);
    }

    return contactUsList;
  }

  Future<void> addContactUsRepo(ContactUsModel caseOfMonthModel) async {
    await FirebaseNodes.contactUsDocumentReference(userId: caseOfMonthModel.id).set(caseOfMonthModel.toMap());
  }

  Future<List<ContactUsModel>> getContactUsFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("ContactUsRepository().getContactUsFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.contactUsCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<ContactUsModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          ContactUsModel productModel = ContactUsModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final ContactUs Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in ContactUsRepository().getContactUsFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}