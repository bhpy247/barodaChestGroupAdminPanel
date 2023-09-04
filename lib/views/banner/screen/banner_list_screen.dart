import 'dart:typed_data';

import 'package:baroda_chest_group_admin/backend/admin/admin_controller.dart';
import 'package:baroda_chest_group_admin/backend/admin/admin_provider.dart';
import 'package:baroda_chest_group_admin/models/admin/property_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_cachednetwork_image.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../backend/common/firebase_storage_controller.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late AdminProvider adminProvider;
  late AdminController adminController;
  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  String? thumbnailImageName;

  PropertyModel? pagePropertyModel;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await adminController.getPropertyDataAndSetInProvider();
  }

  Future<void> addThumbnailImage(int index) async {
    setState(() {});
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      thumbnailImage = await pickedFile.readAsBytes();
      thumbnailImageName = pickedFile.name;
      await addCaseOfMonthToFirebase(index);
      if (mounted) setState(() {});
    }
  }

  Future<String?> uploadFileToFirebaseStorage({
    required String courseId,
    required String imageName,
  }) async {
    String? firebaseStorageImageUrl;
    String finalFileName = MyUtils().getStorageUploadImageUrl(nativeImageName: imageName);
    if (thumbnailImage != null) {
      firebaseStorageImageUrl = await FireBaseStorageController().uploadFilesToFireBaseStorage(data: thumbnailImage!, eventId: courseId, fileName: finalFileName);
      MyPrint.printOnConsole("Method after await");
    }
    return firebaseStorageImageUrl;
  }

  Future<void> addCaseOfMonthToFirebase(int index) async {
    setState(() {
      isLoading = true;
    });

    if (thumbnailImageName != null) {
      thumbnailImageUrl = await uploadFileToFirebaseStorage(courseId: "Banner", imageName: thumbnailImageName!);
    }

    PropertyModel? propertyModel = adminProvider.propertyModel.get();

    if (propertyModel != null) {
     MyPrint.printOnConsole("index : $index : slider length : ${propertyModel.sliders.length}");
     if(index >= propertyModel.sliders.length){
       propertyModel.sliders.add(thumbnailImageUrl ?? "");
     } else {
       propertyModel.sliders[index] = thumbnailImageUrl ?? "";
     }
      await adminController.updateBannerImage(propertyModel);

      // if (pageCourseModel != null) {
      //   CaseOfMonthModel model = pageCourseModel!;
      //   model.caseName = caseOfMonthModel.caseName;
      //   model.description = caseOfMonthModel.description;
      //   model.image = caseOfMonthModel.image;
      //   model.createdTime = caseOfMonthModel.createdTime;
      //   model.updatedTime = caseOfMonthModel.updatedTime;
      // }
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: "updated successfully");
    }
  }

  @override
  void initState() {
    super.initState();
    adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminController = AdminController(adminProvider: adminProvider);

    getData(
      isRefresh: true,
      isFromCache: false,
      isNotify: false,
    );
    /*if (courseProvider.allCoursesLength == 0 && courseProvider.hasMoreCourses.get()) {
      getData(
        isRefresh: true,
        isFromCache: false,
        isNotify: false,
      );
    }*/
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Column(
          children: [
            HeaderWidget(
              title: "Banners",
              // suffixWidget: CommonButton(
              //   text: "Add Brochure",
              //   icon: Icon(
              //     Icons.add,
              //     color: AppColor.white,
              //   ),
              //   onTap: () async {
              //     await NavigationController.navigateToAddBrochureScreen(
              //         navigationOperationParameters: NavigationOperationParameters(
              //           navigationType: NavigationType.pushNamed,
              //           context: context,
              //         ),
              //         addBrochureScreenNavigationArguments: AddBrochureNavigationArguments());
              //     // getData(
              //     //   isRefresh: true,
              //     //   isFromCache: false,
              //     //   isNotify: true,
              //     // );
              //   },
              // ),
            ),
            const SizedBox(height: 20),
            Expanded(child: getCourseList(topContext: context)),
          ],
        ),
      ),
    );
  }

  Widget getCourseList({required BuildContext topContext}) {
    return Consumer(builder: (BuildContext context, AdminProvider adminProvider, Widget? child) {
      // if (adminProvider.propertyModel.get()) {
      //   return const Center(child: CommonProgressIndicator());
      // }

      // if (!brochureProvider.isBrochureLoading.get() && brochureProvider.alBrochureLength == 0) {
      //   return LayoutBuilder(
      //     builder: (BuildContext context, BoxConstraints constraints) {
      //       return RefreshIndicator(
      //         onRefresh: () async {
      //           await getData(
      //             isRefresh: true,
      //             isFromCache: false,
      //             isNotify: true,
      //           );
      //         },
      //         child: ListView(
      //           padding: const EdgeInsets.symmetric(horizontal: 10),
      //           children: [
      //             SizedBox(height: constraints.maxHeight / 2.05),
      //             const Center(
      //               child: Text("No Case of Month"),
      //             ),
      //           ],
      //         ),
      //       );
      //     },
      //   );
      // }

      List<String> banners = adminProvider.propertyModel.get()?.sliders ?? [];

      double? cacheExtent = scrollController.hasClients ? scrollController.position.maxScrollExtent : null;
      // MyPrint.printOnConsole("cacheExtent:$cacheExtent");

      return RefreshIndicator(
        onRefresh: () async {
          await getData(
            isRefresh: true,
            isFromCache: false,
            isNotify: true,
          );
        },
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 20, crossAxisSpacing: 20),
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          cacheExtent: cacheExtent,
          itemCount: 3,
          itemBuilder: (BuildContext context, int index) {
            String image = "";
            if(banners.length > index){
              image = banners[index];
            }
            // String image = "";

            return singleCourse(image, topContext, index);
          },
        ),
      );
    });
  }

  Widget singleCourse(String imageUrl, BuildContext topContext, int index) {
    if (imageUrl.isEmpty) {
      return getAddImageWidget(index);
    }
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        alignment: Alignment.bottomRight,
        fit: StackFit.loose,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: CommonCachedNetworkImage(
              borderRadius: 20,
              imageUrl: imageUrl,
              height: double.maxFinite,
              // height: ,
            ),
          ),
          getEditButton(index)
        ],
      ),
    );
  }

  Widget getEditButton(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: MaterialButton(
        onPressed: () {
          addThumbnailImage(index);
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        color: Colors.white,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: 20,
              color: Colors.black87,
            ),
            SizedBox(
              width: 5,
            ),
            CommonText(
              text: "Edit",
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )
          ],
        ),
      ),
    );
  }

  Widget getAddImageWidget(int index) {
    return InkWell(
      onTap: (){
        addThumbnailImage(index);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 40,
              color: Colors.grey,
            ),
            SizedBox(
              height: 10,
            ),
            CommonText(
              text: "Add banner image",
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            )
          ],
        ),
      ),
    );
  }
}
