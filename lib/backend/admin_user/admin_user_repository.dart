import '../../configs/constants.dart';
import '../../models/admin/admin_user_model.dart';
import '../../utils/my_print.dart';
import '../common/firestore_controller.dart';

class AdminUserRepository{
  Future<AdminUserModel?>  checkLoginAdminMethod({required String adminId,required String password}) async {
    try{
      AdminUserModel? adminModel;
      MyPrint.printOnConsole("query id: $adminId password: $password");

      final query = await FirebaseNodes.adminUsersCollectionReference
          .where('adminId',isEqualTo: adminId).where('password',isEqualTo: password).get();

      MyPrint.printOnConsole("quert data: $query");

      if(query.docs.isNotEmpty) {
        MyPrint.printOnConsole("doc is Not Empty");
        final doc = query.docs[0];
        MyPrint.printOnConsole("doc is Not Empty ${doc.data()}");
        if(doc.data() is Map<String,dynamic>){
          MyPrint.printOnConsole("doc is Not Empty Inside if");

          adminModel = AdminUserModel.fromMap(doc.data() as Map<String,dynamic>);
        }
      }
      MyPrint.printOnConsole("query id model: ${adminModel}");
      return adminModel;
    }catch(e,s){
      MyPrint.printOnConsole("Error in delete check admin login method in admin Repository $e");
      MyPrint.printOnConsole(s);
    }
    return null;
  }

  Future<void> addNewAdminToFirebase({required AdminUserModel adminModel}) async {
    try {

      MyPrint.printOnConsole("Doc id : ${adminModel.adminId}");

      await FirestoreController.firestore.collection('admin_users')
          .doc(adminModel.adminId).set(adminModel.toMap());


      MyPrint.printOnConsole("Admin Added");

    }
    catch(e,s){
      MyPrint.printOnConsole("Error in add new admin in Admin Controller $e");
      MyPrint.printOnConsole(s);
    }
  }
}