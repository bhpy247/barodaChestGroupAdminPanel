
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';

import '../../configs/typedefs.dart';
import '../../models/event/data_model/event_model.dart';
import '../common/common_provider.dart';

class CommitteeMemberProvider extends CommonProvider {
  CommitteeMemberProvider() {
    committeeMemberList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastCommitteeMemberDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreCommitteeMember = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isCommitteeMemberFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isCommitteeMemberLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    committeeMember = CommonProviderListParameter<EventModel>(
      list: [],
      notify: notify,
    );
    isMyCommitteeMemberFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region Brochure Paginated List
  late CommonProviderListParameter<CommitteeMemberModel> committeeMemberList;
  int get allCommitteeMemberLength => committeeMemberList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastCommitteeMemberDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreCommitteeMember;
  late CommonProviderPrimitiveParameter<bool> isCommitteeMemberFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isCommitteeMemberLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allCommitteeMemberLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addCommitteeMemberModelInCourseList(CommitteeMemberModel value, {bool isNotify = true}) {
    committeeMemberList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My Brochure List
  late CommonProviderListParameter<EventModel> committeeMember;

  int get myCommitteeMemberLength => committeeMember.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyCommitteeMemberFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
