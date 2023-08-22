
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';

import '../../configs/typedefs.dart';
import '../../models/event/data_model/event_model.dart';
import '../../models/profile/data_model/gallery_model.dart';
import '../common/common_provider.dart';

class PhotoGalleryProvider extends CommonProvider {
  PhotoGalleryProvider() {
    photoGalleryModelList = CommonProviderListParameter(
      list: [],
      notify: notify,
    );
    lastPhotoGalleryDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMorePhotoGallery = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isPhotoGalleryFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isPhotoGalleryLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    gallery = CommonProviderListParameter<GalleryModel>(
      list: [],
      notify: notify,
    );
    isMyPhotoGalleryFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region PhotoGallery Paginated List
  late CommonProviderListParameter<GalleryModel> photoGalleryModelList;
  int get photoGalleryModelLength => photoGalleryModelList.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastPhotoGalleryDocument;
  late CommonProviderPrimitiveParameter<bool> hasMorePhotoGallery;
  late CommonProviderPrimitiveParameter<bool> isPhotoGalleryFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isPhotoGalleryLoading;

  void updateEnableDisableOfList(bool value, int index, {bool isNotify = true}) {
    if (index < photoGalleryModelLength) {
      // allEvent.elementAtIndex(index)?.enabled = value;
    }

    if (isNotify) {
      notifyListeners();
    }
  }

  void addGalleryModelInCourseList(GalleryModel value, {bool isNotify = true}) {
    photoGalleryModelList.insertAtIndex(index: 0, model: value, isNotify: isNotify);
  }
  //endregion

  //region My PhotoGallery List
  late CommonProviderListParameter<GalleryModel> gallery;

  int get myPhotoGalleryLength => gallery.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyPhotoGalleryFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion
}
