import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';

import '../../configs/typedefs.dart';
import '../common/common_provider.dart';

class AcademicConnectProvider extends CommonProvider {
  AcademicConnectProvider() {
    allEvent = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastCourseDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreAcademicConnect = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isAcademicConnectFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isAcademicConnectLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    events = CommonProviderListParameter<AcademicConnectModel>(
      list: [],
      notify: notify,
    );
    isMyAcademicConnectFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region AcademicConnect Paginated List
  late CommonProviderListParameter<AcademicConnectModel> allEvent;

  int get allAcademicConnectLength => allEvent.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastCourseDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreAcademicConnect;
  late CommonProviderPrimitiveParameter<bool> isAcademicConnectFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isAcademicConnectLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allAcademicConnectLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addCourseModelInCourseList(AcademicConnectModel value, {bool isNotify = true}) {
    allEvent.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }

  //endregion

  //region My AcademicConnect List
  late CommonProviderListParameter<AcademicConnectModel> events;

  int get myAcademicConnectLength => events.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyAcademicConnectFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
//endregion
}
