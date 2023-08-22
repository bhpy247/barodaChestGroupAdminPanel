
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';

import '../../configs/typedefs.dart';
import '../../models/course/data_model/course_model.dart';
import '../../models/event/data_model/event_model.dart';
import '../common/common_provider.dart';

class CaseOfMonthProvider extends CommonProvider {
  CaseOfMonthProvider() {
    caseOfMonthList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastCourseDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreCaseOfMonth = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isCaseOfMonthFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isCaseOfMonthLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    events = CommonProviderListParameter<EventModel>(
      list: [],
      notify: notify,
    );
    isMyCaseOfMonthFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region CaseOfMonth Paginated List
  late CommonProviderListParameter<CaseOfMonthModel> caseOfMonthList;
  int get allCaseOfMonthLength => caseOfMonthList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastCourseDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreCaseOfMonth;
  late CommonProviderPrimitiveParameter<bool> isCaseOfMonthFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isCaseOfMonthLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allCaseOfMonthLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addCaseOfMonthModelInCourseList(CaseOfMonthModel value, {bool isNotify = true}) {
    caseOfMonthList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My CaseOfMonth List
  late CommonProviderListParameter<EventModel> events;

  int get myCaseOfMonthLength => events.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyCaseOfMonthFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
