import 'package:baroda_chest_group_admin/backend/event_backend/event_provider.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/models/course/data_model/course_model.dart';
import 'package:baroda_chest_group_admin/models/event/data_model/event_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/event_backend/event_controller.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class EventScreenNavigator extends StatefulWidget {
  const EventScreenNavigator({Key? key}) : super(key: key);

  @override
  _EventScreenNavigatorState createState() => _EventScreenNavigatorState();
}

class _EventScreenNavigatorState extends State<EventScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.eventScreenNavigator,
      onGenerateRoute: NavigationController.onEventGeneratedRoutes,
    );
  }
}

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({Key? key}) : super(key: key);

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late EventProvider eventProvider;
  late EventController eventController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await eventController.getCoursesPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    eventProvider = Provider.of<EventProvider>(context, listen: false);
    eventController = EventController(eventProvider: eventProvider);

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
              title: "Events",
              suffixWidget: CommonButton(
                text: "Add Events",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddCourseScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addCourseScreenNavigationArguments: AddCourseScreenNavigationArguments());
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
    return Consumer(builder: (BuildContext context, EventProvider courseProvider, Widget? child) {
      if (courseProvider.isCoursesFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!courseProvider.isCoursesLoading.get() && courseProvider.allCoursesLength == 0) {
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

      List<EventModel> events = courseProvider.allEvent.getList(isNewInstance: false);

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
              if (courseProvider.isCoursesLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (courseProvider.hasMoreCourses.get() && index > (events.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                eventController.getCoursesPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            EventModel model = events[index];

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(EventModel eventModel, int index, BuildContext topContext) {
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
                  await NavigationController.navigateToAddCourseScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addCourseScreenNavigationArguments: AddCourseScreenNavigationArguments(
                      eventModel: eventModel,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: eventModel.title,
                    fontSize: 20,
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
