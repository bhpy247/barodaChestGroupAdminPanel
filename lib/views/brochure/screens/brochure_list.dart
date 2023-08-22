import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/utils/my_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/brochure/brochure_controller.dart';
import '../../../backend/brochure/brochure_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../models/brochure/data_model/brochure_model.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class BrochureScreenNavigator extends StatefulWidget {
  const BrochureScreenNavigator({Key? key}) : super(key: key);

  @override
  _BrochureScreenNavigatorState createState() => _BrochureScreenNavigatorState();
}

class _BrochureScreenNavigatorState extends State<BrochureScreenNavigator>  {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.brochureScreenNavigator,
      onGenerateRoute: NavigationController.onBrochureGeneratedRoutes,
    );
  }
}

class BrochureListScreen extends StatefulWidget {
  const BrochureListScreen({super.key});

  @override
  State<BrochureListScreen> createState() => _BrochureListScreenState();
}

class _BrochureListScreenState extends State<BrochureListScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late BrochureProvider brochureProvider;
  late BrochureController brochureController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await brochureController.getBrochurePaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    brochureProvider = Provider.of<BrochureProvider>(context, listen: false);
    brochureController = BrochureController(brochureProvider: brochureProvider);

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
              title: "Brochure",
              suffixWidget: CommonButton(
                text: "Add Brochure",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddBrochureScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addBrochureScreenNavigationArguments: AddBrochureNavigationArguments());
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
    return Consumer(builder: (BuildContext context, BrochureProvider brochureProvider, Widget? child) {
      if (brochureProvider.isBrochureFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!brochureProvider.isBrochureLoading.get() && brochureProvider.alBrochureLength == 0) {
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

      List<BrochureModel> caseOfMonth = brochureProvider.brochureList.getList(isNewInstance: false);

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
          itemCount: caseOfMonth.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if ((index == 0 && caseOfMonth.isEmpty) || (index == caseOfMonth.length)) {
              if (brochureProvider.isBrochureLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (brochureProvider.hasMoreBrochure.get() && index > (caseOfMonth.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                brochureController.getBrochurePaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            BrochureModel model = caseOfMonth[index];

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(BrochureModel caseOfMonthModel, int index, BuildContext topContext) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Want to Edit course?",
                rightText: "Yes",
                rightOnTap: () async {
                  Navigator.pop(context);
                  await NavigationController.navigateToAddBrochureScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addBrochureScreenNavigationArguments: AddBrochureNavigationArguments(
                      brochureModel: caseOfMonthModel,
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
                      text: caseOfMonthModel.brochureName,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: caseOfMonthModel.createdTime == null ? 'Created Date: No Data' : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(caseOfMonthModel.createdTime!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if(caseOfMonthModel.brochureUrl.isNotEmpty)
              InkWell(
                  onTap:(){

                    MyUtils.launchUrlString(url: caseOfMonthModel.brochureUrl);
                  },
                  child: Icon(Icons.remove_red_eye))
            ],
          ),
        ),
      ),
    );
  }
}
