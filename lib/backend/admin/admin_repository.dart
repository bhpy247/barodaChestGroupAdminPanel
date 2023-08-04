import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/admin/property_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class AdminRepository {
  Future<PropertyModel?> getPropertyData() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminRepository().getPropertyData() called", tag: tag);

    PropertyModel? propertyModel;

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminPropertyDocumentReference.get();
      MyPrint.printOnConsole("snapshot exist:${snapshot.exists}", tag: tag);
      MyPrint.printOnConsole("snapshot data:${snapshot.data()}", tag: tag);

      if(snapshot.data()?.isNotEmpty ?? false) {
        propertyModel = PropertyModel.fromMap(snapshot.data()!);
      }
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:$propertyModel", tag: tag);

    return propertyModel;
  }
}