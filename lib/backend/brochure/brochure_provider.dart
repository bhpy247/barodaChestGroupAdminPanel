
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/typedefs.dart';
import '../../models/event/data_model/event_model.dart';
import '../common/common_provider.dart';

class BrochureProvider extends CommonProvider {
  BrochureProvider() {
    brochureList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastBrochureDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreBrochure = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isBrochureFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isBrochureLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    events = CommonProviderListParameter<EventModel>(
      list: [],
      notify: notify,
    );
    isMyBrochureFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region Brochure Paginated List
  late CommonProviderListParameter<BrochureModel> brochureList;
  int get alBrochureLength => brochureList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastBrochureDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreBrochure;
  late CommonProviderPrimitiveParameter<bool> isBrochureFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isBrochureLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < alBrochureLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addBrochureModelInCourseList(BrochureModel value, {bool isNotify = true}) {
    brochureList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My Brochure List
  late CommonProviderListParameter<EventModel> events;

  int get myBrochureLength => events.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyBrochureFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
