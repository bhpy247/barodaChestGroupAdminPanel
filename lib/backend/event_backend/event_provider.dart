
import '../../configs/typedefs.dart';
import '../../models/course/data_model/course_model.dart';
import '../../models/event/data_model/event_model.dart';
import '../common/common_provider.dart';

class EventProvider extends CommonProvider {
  EventProvider() {
    allEvent = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastCourseDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreCourses = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isCoursesFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isCoursesLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    events = CommonProviderListParameter<EventModel>(
      list: [],
      notify: notify,
    );
    isMyCoursesFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region Courses Paginated List
  late CommonProviderListParameter<EventModel> allEvent;
  int get allCoursesLength => allEvent.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastCourseDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreCourses;
  late CommonProviderPrimitiveParameter<bool> isCoursesFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isCoursesLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allCoursesLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addCourseModelInCourseList(EventModel value, {bool isNotify = true}) {
    allEvent.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My Courses List
  late CommonProviderListParameter<EventModel> events;

  int get myCoursesLength => events.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyCoursesFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
