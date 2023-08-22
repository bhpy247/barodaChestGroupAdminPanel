import 'package:baroda_chest_group_admin/backend/guide_line/guideline_controller.dart';
import 'package:baroda_chest_group_admin/backend/guide_line/guideline_provider.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../models/profile/data_model/guideline_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class GuidelineScreenNavigator extends StatefulWidget {
  const GuidelineScreenNavigator({Key? key}) : super(key: key);

  @override
  _GuidelineScreenNavigatorState createState() => _GuidelineScreenNavigatorState();
}

class _GuidelineScreenNavigatorState extends State<GuidelineScreenNavigator>  {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.guidelineScreenNavigator,
      onGenerateRoute: NavigationController.onGuidelineGeneratedRoutes,
    );
  }
}


class GuideLineScreen extends StatefulWidget {
  const GuideLineScreen({super.key});

  @override
  State<GuideLineScreen> createState() => _GuideLineScreenState();
}

class _GuideLineScreenState extends State<GuideLineScreen> with MySafeState{
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late GuidelineProvider guidelineProvider;
  late GuidelineController guidelineController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await guidelineController.getGuidelinePaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    guidelineProvider = Provider.of<GuidelineProvider>(context, listen: false);
    guidelineController = GuidelineController(guidelineProvider: guidelineProvider);

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
              title: "Guide Line",
              suffixWidget: CommonButton(
                text: "Add guideLine",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddGuidelineScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addGuidelineNavigationArguments: AddGuidelineNavigationArguments());
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
    return Consumer(builder: (BuildContext context, GuidelineProvider guidelineProvider, Widget? child) {
      if (guidelineProvider.isGuidelineFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!guidelineProvider.isGuidelineLoading.get() && guidelineProvider.alGuidelineLength == 0) {
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
                    child: Text("No Case of Month"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<GuidelineModel> guidelineModel = guidelineProvider.guidelineList.getList(isNewInstance: false);

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
          itemCount: guidelineModel.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if ((index == 0 && guidelineModel.isEmpty) || (index == guidelineModel.length)) {
              if (guidelineProvider.isGuidelineLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (guidelineProvider.hasMoreGuideline.get() && index > (guidelineModel.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                guidelineController.getGuidelinePaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            GuidelineModel model = guidelineModel[index];

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(GuidelineModel guidelineModel, int index, BuildContext topContext) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Want to Edit Guideline?",
                rightText: "Yes",
                rightOnTap: () async {
                  Navigator.pop(context);
                  await NavigationController.navigateToAddGuidelineScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addGuidelineNavigationArguments: AddGuidelineNavigationArguments(
                      guidelineModel: guidelineModel,
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
                      text: guidelineModel.name,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: guidelineModel.createdTime == null ? 'Created Date: No Data' : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(guidelineModel.createdTime!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if(guidelineModel.downloadUrl.isNotEmpty)
                InkWell(
                    onTap:(){

                      MyUtils.launchUrlString(url: guidelineModel.downloadUrl);
                    },
                    child: Icon(Icons.remove_red_eye))
            ],
          ),
        ),
      ),
    );
  }
}
