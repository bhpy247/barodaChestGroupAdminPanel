

import '../../configs/typedefs.dart';
import '../../models/event/data_model/event_model.dart';
import '../../models/profile/data_model/member_model.dart';
import '../common/common_provider.dart';

class MemberProvider extends CommonProvider {
  MemberProvider() {
    memberList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastMemberDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreMember = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isMemberFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isMemberLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    member = CommonProviderListParameter<EventModel>(
      list: [],
      notify: notify,
    );
    isMyMemberFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region Member Paginated List
  late CommonProviderListParameter<MemberModel> memberList;
  int get allMemberLength => memberList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastMemberDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreMember;
  late CommonProviderPrimitiveParameter<bool> isMemberFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isMemberLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allMemberLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addMemberModelInCourseList(MemberModel value, {bool isNotify = true}) {
    memberList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My Member List
  late CommonProviderListParameter<EventModel> member;

  int get myMemberLength => member.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyMemberFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
