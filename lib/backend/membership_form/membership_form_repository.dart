import 'package:baroda_chest_group_admin/models/profile/data_model/membership_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class MembershipFormRepository {
  Future<List<MembershipModel>> getMembershipFormListRepo() async {
    List<MembershipModel> membershipFormList = [];

    try {
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.membershipCollectionReference.get();
      if (querySnapshot.docs.isNotEmpty) {
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if (queryDocumentSnapshot.data().isNotEmpty) {
            membershipFormList.add(MembershipModel.fromMap(queryDocumentSnapshot.data()));
          } else {
            MyPrint.printOnConsole("MembershipForm Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    } catch (e, s) {
      MyPrint.printOnConsole('Error in getMembershipFormRepo in MembershipFormRepository $e');
      MyPrint.printOnConsole(s);
    }

    return membershipFormList;
  }

  Future<void> addMembershipFormRepo(MembershipModel caseOfMonthModel) async {
    await FirebaseNodes.membershipDocumentReference(userId: caseOfMonthModel.id).set(caseOfMonthModel.toMap());
  }

  Future<List<MembershipModel>> getMembershipFormFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("MembershipFormRepository().getMembershipFormFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.membershipCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<MembershipModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if ((documentSnapshot.data() ?? {}).isNotEmpty) {
          MembershipModel productModel = MembershipModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final MembershipForm Length From Firestore:${list.length}", tag: tag);

      return list;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MembershipFormRepository().getMembershipFormFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }
}
