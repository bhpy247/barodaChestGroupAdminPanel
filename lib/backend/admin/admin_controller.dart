import '../../models/admin/property_model.dart';
import '../../models/common/data_model/new_document_data_model.dart';
import '../../models/other/data_model/feedback_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'admin_provider.dart';
import 'admin_repository.dart';

class AdminController {
  late AdminProvider _adminProvider;
  late AdminRepository _adminRepository;

  AdminController({required AdminProvider? adminProvider, AdminRepository? repository}) {
    _adminProvider = adminProvider ?? AdminProvider();
    _adminRepository = repository ?? AdminRepository();
  }

  AdminProvider get adminProvider => _adminProvider;

  AdminRepository get adminRepository => _adminRepository;

  Future<void> getPropertyDataAndSetInProvider() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminController().getPropertyDataAndSetInProvider() called", tag: tag);

    try {
      PropertyModel? propertyModel = await adminRepository.getPropertyData();

      adminProvider.propertyModel.set(value: propertyModel);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:${adminProvider.propertyModel.get()}", tag: tag);
  }

  Future<void> getAssetsUploadModelAndSaveInProvider() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().getPropertyModelAndSaveInProvider() called", tag: tag);

    try {
      AssetsUploadModel? assetsUploadedModel = await adminRepository.getAssetsModel();
      adminProvider.assetsUploadedModel.set(value: assetsUploadedModel);

      MyPrint.printOnConsole("assetsUploadedModel:$assetsUploadedModel", tag: tag);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().getAssetsUploadModelAndSaveInProvider():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<void> updatePropertyDataAndSetInProvider() async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminController().getPropertyDataAndSetInProvider() called", tag: tag);

    try {
      PropertyModel? propertyModel = await adminRepository.getPropertyData();

      adminProvider.propertyModel.set(value: propertyModel);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:${adminProvider.propertyModel.get()}", tag: tag);
  }

  Future<void> updatePropertyDataOnlineAndSetInProvider(PropertyModel propertyModel) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminController().getPropertyDataAndSetInProvider() called", tag: tag);

    try {
      bool isSuccess = await adminRepository.updatePropertyData(propertyModel.toMap());
      if (isSuccess) {
        adminProvider.propertyModel.set(value: propertyModel);
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().updatePropertyDataOnlineAndSetInProvider():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:${adminProvider.propertyModel.get()}", tag: tag);
  }

  Future<void> updateAssetModelDataAndSetInProvider(AssetsUploadModel assetsUploadModel) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminController().updateAssetModelDataAndSetInProvider() called", tag: tag);

    try {
      bool? isSuccess = await adminRepository.updateAssetsModalData(assetsUploadModel.toMap());
      if (isSuccess) {
        adminProvider.assetsUploadedModel.set(value: assetsUploadModel);
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().updateAssetModelDataAndSetInProvider():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:${adminProvider.assetsUploadedModel.get()}", tag: tag);
  }

  Future<void> updateBannerImage(PropertyModel propertyModel) async {
    String tag = MyUtils.getUniqueIdFromUuid();
    MyPrint.printOnConsole("AdminController().updateBannerImage() called", tag: tag);

    try {
      bool isSuccess = await adminRepository.updatePropertyData(propertyModel.toMap());
      if (isSuccess) {
        adminProvider.propertyModel.set(value: propertyModel);
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in getting PropertyModel in AdminRepository().getPropertyData():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("Final propertyModel:${adminProvider.propertyModel.get()}", tag: tag);
  }

  Future<void> getNewTimestampAndSaveInProvider() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().getNewTimestampAndSaveInProvider() called", tag: tag);

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      adminProvider.timeStamp.set(value: newDocumentDataModel.timestamp);

      MyPrint.printOnConsole("new timeStamp:${newDocumentDataModel.timestamp.toDate()}", tag: tag);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().getNewTimestampAndSaveInProvider():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<List<FeedbackModel>> getFeedbacks({bool isRefresh = true}) async {
    return [];
  }

  Future<bool> deleteFeedback(String feedbackId) async {
    return true;
  }
}
