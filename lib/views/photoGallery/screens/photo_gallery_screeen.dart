import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/backend/photo_gallery/photo_gallery_controller.dart';
import 'package:baroda_chest_group_admin/backend/photo_gallery/photo_gallery_provider.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/utils/my_print.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_cachednetwork_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_safe_state.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class PhotoGalleryScreenNavigator extends StatefulWidget {
  const PhotoGalleryScreenNavigator({Key? key}) : super(key: key);

  @override
  _PhotoGalleryScreenNavigatorState createState() => _PhotoGalleryScreenNavigatorState();
}

class _PhotoGalleryScreenNavigatorState extends State<PhotoGalleryScreenNavigator>  {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.photoGalleryScreenNavigator,
      onGenerateRoute: NavigationController.onPhotoGalleryGeneratedRoutes,
    );
  }
}

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late PhotoGalleryProvider photoGalleryProvider;
  late PhotoGalleryController brochureController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await brochureController.getPhotoGalleryPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    photoGalleryProvider = Provider.of<PhotoGalleryProvider>(context, listen: false);
    brochureController = PhotoGalleryController(photoGalleryProvider: photoGalleryProvider);

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
              title: "Photo Gallery",
              suffixWidget: CommonButton(
                text: "Add Photo Gallery",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddPhotoGalleryScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addPhotoGalleryScreenNavigationArguments: AddPhotoGalleryNavigationArguments());
                  // getData(
                  //   isRefresh: true,
                  //   isFromCache: false,
                  //   isNotify: true,
                  // );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: getCourseList(topContext: context)),
          ],
        ),
      ),
    );
  }

  Widget getCourseList({required BuildContext topContext}) {
    return Consumer(builder: (BuildContext context, PhotoGalleryProvider photoGalleryProvider, Widget? child) {
      if (photoGalleryProvider.isPhotoGalleryFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!photoGalleryProvider.isPhotoGalleryLoading.get() && photoGalleryProvider.photoGalleryModelLength == 0) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return RefreshIndicator(
              onRefresh: () async {
                await getData(
                  isRefresh: true,
                  isFromCache: false,
                  isNotify: true,
                );
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  SizedBox(height: constraints.maxHeight / 2.05),
                  const Center(
                    child: Text("No Photo Albums"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<GalleryModel> photoGalleryList = photoGalleryProvider.photoGalleryModelList.getList(isNewInstance: false);

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
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          cacheExtent: cacheExtent,
          itemCount: photoGalleryList.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if ((index == 0 && photoGalleryList.isEmpty) || (index == photoGalleryList.length)) {
              if (photoGalleryProvider.isPhotoGalleryLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (photoGalleryProvider.hasMorePhotoGallery.get() && index > (photoGalleryList.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                brochureController.getPhotoGalleryPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            GalleryModel model = photoGalleryList[index];

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(GalleryModel photoGalleryModel, int index, BuildContext topContext) {
    MyPrint.printOnConsole("photoGalleryModel.imageList : ${photoGalleryModel.eventName } : ${photoGalleryModel.imageList.length}");
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Want to Edit Photo Gallery?",
                rightText: "Yes",
                rightOnTap: () async {
                  Navigator.pop(context);
                  await NavigationController.navigateToAddPhotoGalleryScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addPhotoGalleryScreenNavigationArguments: AddPhotoGalleryNavigationArguments(
                      galleryModel: photoGalleryModel,
                      index: index,
                      isEdit: true,
                    ),
                  );
                  mySetState();
                },
              );
            },
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.white,
            border: Border.all(color: AppColor.yellow, width: 1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: photoGalleryModel.eventName,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: photoGalleryModel.createdTime == null ? 'Created Date: No Data' : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(photoGalleryModel.createdTime!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.end,
                  children: photoGalleryModel.imageList.map((e) {
                    MyPrint.printOnConsole("Helloe : ${e}");
                    return CommonCachedNetworkImage(imageUrl: e, height: 50,width: 50, borderRadius: 10,);
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
