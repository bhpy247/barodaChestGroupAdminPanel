import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_controller.dart';
import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_provider.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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

class AcademicConnectNavigator extends StatefulWidget {
  const AcademicConnectNavigator({Key? key}) : super(key: key);

  @override
  _AcademicConnectNavigatorState createState() => _AcademicConnectNavigatorState();
}

class _AcademicConnectNavigatorState extends State<AcademicConnectNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.academicConnectScreenNavigator,
      onGenerateRoute: NavigationController.onAcademicConnectGeneratedRoutes,
    );
  }
}

class AcademicConnectListScreen extends StatefulWidget {
  const AcademicConnectListScreen({Key? key}) : super(key: key);

  @override
  State<AcademicConnectListScreen> createState() => _AcademicConnectListScreenState();
}

class _AcademicConnectListScreenState extends State<AcademicConnectListScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late AcademicConnectProvider academicConnectProvider;
  late AcademicConnectController academicConnectController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await academicConnectController.getAcademicConnectPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    academicConnectProvider = Provider.of<AcademicConnectProvider>(context, listen: false);
    academicConnectController = AcademicConnectController(academicConnectProvider: academicConnectProvider);

    getData(
      isRefresh: true,
      isFromCache: false,
      isNotify: false,
    );
    /*if (courseProvider.allAcademicConnectLength == 0 && courseProvider.hasMoreAcademicConnect.get()) {
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
              title: "Academic Connect",
              suffixWidget: CommonButton(
                text: "Add Academic Connect",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddAcademicConnectScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      academicConnectScreenNavigationArguments: AddAcademicConnectScreenNavigationArguments());
                  getData(
                    isRefresh: true,
                    isFromCache: false,
                    isNotify: true,
                  );
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
    return Consumer(builder: (BuildContext context, AcademicConnectProvider courseProvider, Widget? child) {
      if (courseProvider.isAcademicConnectFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!courseProvider.isAcademicConnectLoading.get() && courseProvider.allAcademicConnectLength == 0) {
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
                    child: Text("No AcademicConnect"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<AcademicConnectModel> academicConnect = courseProvider.allEvent.getList(isNewInstance: false);

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
          itemCount: academicConnect.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if ((index == 0 && academicConnect.isEmpty) || (index == academicConnect.length)) {
              if (courseProvider.isAcademicConnectLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (courseProvider.hasMoreAcademicConnect.get() && index > (academicConnect.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                academicConnectController.getAcademicConnectPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            AcademicConnectModel model = academicConnect[index];

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(AcademicConnectModel eventModel, int index, BuildContext topContext) {
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
                  await NavigationController.navigateToAddAcademicConnectScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    academicConnectScreenNavigationArguments: AddAcademicConnectScreenNavigationArguments(
                      academicConnectModel: eventModel,
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
                  imageUrl: eventModel.imageUrl,
                  height: 80,
                  width: 80,
                  borderRadius: 4,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: eventModel.title,
                      fontSize: 20,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: eventModel.createdTime == null ? 'Created Date: No Data' : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(eventModel.createdTime!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTestEnableSwitch({required bool value, void Function(bool?)? onChanged}) {
    return Tooltip(
      message: value ? 'Enabled' : 'Disabled',
      child: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColor.bgSideMenu,
      ),
    );
  }
}
