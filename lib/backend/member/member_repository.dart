
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class MemberRepository {

  Future<List<MemberModel>> getMemberListRepo() async {
    List<MemberModel> memberList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.memberCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            memberList.add(MemberModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Brochure Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getBrochureRepo in MemberRepository $e');
      MyPrint.printOnConsole(s);
    }

    return memberList;
  }

  Future<void> addMemberRepo(MemberModel memberModel) async {
    await FirebaseNodes.memberDocumentReference(docId: memberModel.id).set(memberModel.toMap());
  }

  Future<List<MemberModel>> getBrochureFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("MemberRepository().getBrochureFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.memberCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<MemberModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          MemberModel productModel = MemberModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in MemberRepository().getBrochureFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}