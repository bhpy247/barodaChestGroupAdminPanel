import 'package:baroda_chest_group_admin/models/profile/data_model/membership_model.dart';

import '../../configs/typedefs.dart';
import '../common/common_provider.dart';

class MembershipFormProvider extends CommonProvider {
  MembershipFormProvider() {
    membershipFormList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastMembershipFormDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreMembershipForm = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isMembershipFormFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isMembershipFormLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    MembershipForm = CommonProviderListParameter<MembershipModel>(
      list: [],
      notify: notify,
    );
    isMyMembershipFormFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region ContactUs Paginated List
  late CommonProviderListParameter<MembershipModel> membershipFormList;

  int get allMembershipFormLength => membershipFormList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastMembershipFormDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreMembershipForm;
  late CommonProviderPrimitiveParameter<bool> isMembershipFormFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isMembershipFormLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allMembershipFormLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addMembershipModel(MembershipModel value, {bool isNotify = true}) {
    membershipFormList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }

  //endregion

  //region My ContactUs List
  late CommonProviderListParameter<MembershipModel> MembershipForm;

  int get myContactUsLength => MembershipForm.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyMembershipFormFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
//endregion
}
