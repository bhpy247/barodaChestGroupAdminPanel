
import 'package:baroda_chest_group_admin/models/profile/data_model/guideline_model.dart';

import '../../configs/typedefs.dart';
import '../../models/event/data_model/event_model.dart';
import '../common/common_provider.dart';

class GuidelineProvider extends CommonProvider {
  GuidelineProvider() {
    guidelineList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastGuidelineDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreGuideline = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isGuidelineFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isGuidelineLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    guideLine = CommonProviderListParameter<GuidelineModel>(
      list: [],
      notify: notify,
    );
    isMyGuidelineFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region Guideline Paginated List
  late CommonProviderListParameter<GuidelineModel> guidelineList;
  int get alGuidelineLength => guidelineList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastGuidelineDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreGuideline;
  late CommonProviderPrimitiveParameter<bool> isGuidelineFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isGuidelineLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < alGuidelineLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addGuidelineModelInCourseList(GuidelineModel value, {bool isNotify = true}) {
    guidelineList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My Guideline List
  late CommonProviderListParameter<GuidelineModel> guideLine;

  int get myGuidelineLength => guideLine.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyGuidelineFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
