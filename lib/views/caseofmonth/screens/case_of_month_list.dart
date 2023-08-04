import 'package:baroda_chest_group_admin/backend/case_of_month/case_of_month_controller.dart';
import 'package:baroda_chest_group_admin/backend/case_of_month/case_of_month_provider.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/event_backend/event_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class CaseOfMonthScreenNavigator extends StatefulWidget {
  const CaseOfMonthScreenNavigator({Key? key}) : super(key: key);

  @override
  _CaseOfMonthScreenNavigatorState createState() => _CaseOfMonthScreenNavigatorState();
}

class _CaseOfMonthScreenNavigatorState extends State<CaseOfMonthScreenNavigator>  {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.caseOfMonthScreenNavigator,
      onGenerateRoute: NavigationController.onCaseOfMonthGeneratedRoutes,
    );
  }
}

class CaseOfMonthList extends StatefulWidget {
  const CaseOfMonthList({super.key});

  @override
  State<CaseOfMonthList> createState() => _CaseOfMonthListState();
}

class _CaseOfMonthListState extends State<CaseOfMonthList> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late CaseOfMonthProvider caseOfMonthProvider;
  late CaseOfMonthController caseOfMonthController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await caseOfMonthController.getCaseOfMonthPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    caseOfMonthProvider = Provider.of<CaseOfMonthProvider>(context, listen: false);
    caseOfMonthController = CaseOfMonthController(caseOfMonthProvider: caseOfMonthProvider);

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
              title: "Case Of Month",
              suffixWidget: CommonButton(
                text: "Add Case Of Month",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddCaseOfMonthScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addCourseScreenNavigationArguments: AddCaseOfMonthScreenNavigationArguments());
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
    return Consumer(builder: (BuildContext context, CaseOfMonthProvider caseOfMonthProvider, Widget? child) {
      if (caseOfMonthProvider.isCaseOfMonthFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!caseOfMonthProvider.isCaseOfMonthLoading.get() && caseOfMonthProvider.allCaseOfMonthLength == 0) {
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
                    child: Text("No Courses"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<CaseOfMonthModel> events = caseOfMonthProvider.caseOfMonthList.getList(isNewInstance: false);

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
          itemCount: events.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if ((index == 0 && events.isEmpty) || (index == events.length)) {
              if (caseOfMonthProvider.isCaseOfMonthLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (caseOfMonthProvider.hasMoreCaseOfMonth.get() && index > (events.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                caseOfMonthController.getCaseOfMonthPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            CaseOfMonthModel model = events[index];

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(CaseOfMonthModel caseOfMonthModel, int index, BuildContext topContext) {
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
                  await NavigationController.navigateToAddCaseOfMonthScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addCourseScreenNavigationArguments: AddCaseOfMonthScreenNavigationArguments(
                      caseOfMonthModel: caseOfMonthModel,
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColor.bgSideMenu.withOpacity(.6)),
                ),
                // child: Image.network(
                //   eventModel.imageUrl,
                //   height: 80,
                //   width: 80,
                // ),
                child: CommonCachedNetworkImage(
                  imageUrl: caseOfMonthModel.image,
                  height: 80,
                  width: 80,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: caseOfMonthModel.caseName,
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
              const SizedBox(width: 20),
              const Spacer(),
              // InkWell(
              //   onTap: (){},
              //   child: Tooltip(
              //     message: 'Copy New Game',
              //     child: Padding(
              //       padding: const EdgeInsets.all(5.0),
              //       child: Icon(Icons.copy,color: AppColor.bgSideMenu),
              //     ),
              //   ),
              // ),
              const SizedBox(width: 20),
              // getTestEnableSwitch(
              //   value: eventModel.enabled,
              //   onChanged: (val) {
              //     Map<String, dynamic> data = {
              //       "enabled": val,
              //     };
              //     // eventController.enableDisableCourseInFirebase(editableData: data, id: courseModel.id, listIndex: index);
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
