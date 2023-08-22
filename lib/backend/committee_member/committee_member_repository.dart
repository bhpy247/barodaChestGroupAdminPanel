
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class CommitteeMemberRepository {

  Future<List<CommitteeMemberModel>> getCommitteeMemberListRepo() async {
    List<CommitteeMemberModel> committeeMemberList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.committeeMemberCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            committeeMemberList.add(CommitteeMemberModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Brochure Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getBrochureRepo in CommitteeMemberRepository $e');
      MyPrint.printOnConsole(s);
    }

    return committeeMemberList;
  }

  Future<void> addCommitteeMemberRepo(CommitteeMemberModel committeeMemberModel) async {
    await FirebaseNodes.committeeMemberDocumentReference(userId: committeeMemberModel.id).set(committeeMemberModel.toMap());
  }

  Future<List<CommitteeMemberModel>> getCommitteeMemberFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CommitteeMemberRepository().getBrochureFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.committeeMemberCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<CommitteeMemberModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          CommitteeMemberModel productModel = CommitteeMemberModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CommitteeMemberRepository().getBrochureFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}