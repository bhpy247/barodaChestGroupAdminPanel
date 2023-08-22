
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../common/firestore_controller.dart';

class PhotoGalleryRepository {

  Future<List<GalleryModel>> getPhotoGalleryListRepo() async {
    List<GalleryModel> photoGalleryList = [];

    try{
      MyFirestoreQuerySnapshot querySnapshot = await FirebaseNodes.galleryCollectionReference.get();
      if(querySnapshot.docs.isNotEmpty){
        for (MyFirestoreQueryDocumentSnapshot queryDocumentSnapshot in querySnapshot.docs) {
          if(queryDocumentSnapshot.data().isNotEmpty) {
            photoGalleryList.add(GalleryModel.fromMap(queryDocumentSnapshot.data()));
          }
          else {
            MyPrint.printOnConsole("Brochure Document Empty for Document Id:${queryDocumentSnapshot.id}");
          }
        }
      }
    }catch(e,s){
      MyPrint.printOnConsole('Error in getBrochureRepo in PhotoGalleryRepository $e');
      MyPrint.printOnConsole(s);
    }

    return photoGalleryList;
  }

  Future<void> addBrochureRepo(GalleryModel galleryModel) async {
    await FirebaseNodes.galleryDocumentReference(documentId: galleryModel.id).set(galleryModel.toMap());
  }

  Future<List<GalleryModel>> getGalleryModelFromIdsList({required List<String> courseIds}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("PhotoGalleryRepository().getBrochureFromIdsList called with brochureId:'$courseIds'", tag: tag);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.galleryCollectionReference,
        docIds: courseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for brochure:${docs.length}", tag: tag);

      List<GalleryModel> list = [];
      for (MyFirestoreDocumentSnapshot documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          GalleryModel productModel = GalleryModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      MyPrint.printOnConsole("Final Brochure Length From Firestore:${list.length}", tag: tag);

      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in PhotoGalleryRepository().getBrochureFromIdsList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return [];
    }
  }

}