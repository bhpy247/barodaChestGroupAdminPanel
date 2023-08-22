

import '../../configs/typedefs.dart';
import '../../models/event/data_model/event_model.dart';
import '../../models/profile/data_model/contact_us_model.dart';
import '../common/common_provider.dart';

class ContactUsProvider extends CommonProvider {
  ContactUsProvider() {
    contactUsList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastContactUsDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreContactUs = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isContactUsFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isContactUsLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    contactUs = CommonProviderListParameter<ContactUsModel>(
      list: [],
      notify: notify,
    );
    isMyContactUsFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region ContactUs Paginated List
  late CommonProviderListParameter<ContactUsModel> contactUsList;
  int get allContactUsLength => contactUsList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastContactUsDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreContactUs;
  late CommonProviderPrimitiveParameter<bool> isContactUsFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isContactUsLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < allContactUsLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addContactUsModelInCourseList(ContactUsModel value, {bool isNotify = true}) {
    contactUsList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My ContactUs List
  late CommonProviderListParameter<ContactUsModel> contactUs;

  int get myContactUsLength => contactUs.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyContactUsFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
