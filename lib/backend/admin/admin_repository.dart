import 'package:baroda_chest_group_admin/utils/extensions.dart';

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
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:$propertyModel", tag: tag);

    return propertyModel;
  }

  Future<AssetsUploadModel?> getAssetsModel() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminRepository().getAssetsModel() called", tag: tag);

    AssetsUploadModel? assetsUploadModel;
    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.assetsUploadedPropertyDocumentReference.get();
      MyPrint.printOnConsole("Property Snapshot Data:${snapshot.data()}", tag: tag);

      if (snapshot.exists && snapshot.data().checkNotEmpty) {
        assetsUploadModel = AssetsUploadModel.fromMap(snapshot.data()!);
      }

      MyPrint.printOnConsole("propertyModel:$assetsUploadModel", tag: tag);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminRepository().getPropertyModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return assetsUploadModel;
  }

  Future<bool> updatePropertyData(Map<String, dynamic> updateMap) async {
    bool isSuccess = false;
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminRepository().getPropertyData() called", tag: tag);

    PropertyModel? propertyModel;

    try {
      await FirebaseNodes.adminPropertyDocumentReference.update(updateMap).then((value) {
        isSuccess = true;
      });
      MyPrint.printOnConsole("isSuccess:${isSuccess}", tag: tag);

      return isSuccess;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().updatePropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return false;
  }

  Future<bool> updateAssetsModalData(Map<String, dynamic> updateMap) async {
    bool isSuccess = false;
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminRepository().getPropertyData() called", tag: tag);

    try {
      await FirebaseNodes.assetsUploadedPropertyDocumentReference.update(updateMap).then((value) {
        isSuccess = true;
      });
      MyPrint.printOnConsole("isSuccess:${isSuccess}", tag: tag);

      return isSuccess;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().updatePropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return false;
  }
}