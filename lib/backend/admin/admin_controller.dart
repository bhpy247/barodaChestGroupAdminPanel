import 'package:cloud_firestore/cloud_firestore.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/admin/property_model.dart';
import '../../models/common/data_model/new_document_data_model.dart';
import '../../models/other/data_model/faq_model.dart';
import '../../models/other/data_model/feedback_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';
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
