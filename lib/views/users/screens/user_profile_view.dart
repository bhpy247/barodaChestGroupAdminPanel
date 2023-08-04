import 'package:baroda_chest_group_admin/backend/admin/admin_provider.dart';
import 'package:baroda_chest_group_admin/backend/event_backend/event_controller.dart';
import 'package:baroda_chest_group_admin/backend/event_backend/event_provider.dart';
import 'package:baroda_chest_group_admin/models/course/data_model/course_model.dart';
import 'package:baroda_chest_group_admin/models/event/data_model/event_model.dart';
import 'package:baroda_chest_group_admin/models/user/data_model/user_course_enrollment_model.dart';
import 'package:baroda_chest_group_admin/models/user/data_model/user_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_print.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/utils/my_toast.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_button.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_cachednetwork_image.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_popup.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_text.dart';
import 'package:baroda_chest_group_admin/views/common/components/get_title.dart';
import 'package:baroda_chest_group_admin/views/common/components/modal_progress_hud.dart';
import 'package:baroda_chest_group_admin/views/users/componants/assign_course_validity_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/users_backend/user_controller.dart';
import '../../../backend/users_backend/user_provider.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/header_widget.dart';

class UserProfileView extends StatefulWidget {
  static const String routeName = "/UserProfileView";
  final UserProfileViewScreenNavigationArguments arguments;

  const UserProfileView({Key? key, required this.arguments}) : super(key: key);

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> with MySafeState {
  late UserProvider userProvider;
  late UserController userController;

  late EventProvider eventProvider;
  late EventController eventController;

  late AdminProvider adminProvider;

  String userId = "";
  UserModel? pageUserModel;
  late Future<void> futureGetData;

  bool isLoading = false;

  Future<void> getUsersData() async {
    MyPrint.printOnConsole("getUsersData called");

    userId = widget.arguments.userId;
    eventProvider.userId.set(value: userId, isNotify: false);
    MyPrint.printOnConsole("userId:$userId");

    MyPrint.printOnConsole("userId:${widget.arguments.userModel}");
    pageUserModel = widget.arguments.userModel;
    if (pageUserModel == null && userId.isNotEmpty) {
      pageUserModel = await userController.userRepository.getUserModelFromId(userId: userId);
    }
    MyPrint.printOnConsole("Final userId:'$userId'");
    MyPrint.printOnConsole("Final pageUserModel:'$pageUserModel'");

    if (pageUserModel != null) {
      await getAssignedCourses(courseIds: pageUserModel!.myCoursesData.keys.toList());
    }
  }

  Future<void> getAssignedCourses({required List<String> courseIds}) async {
    // await eventController.getUserCoursesList(myCourseIds: courseIds);
  }

  Future<void> extendValidityOfCourseOnTap({required CourseModel courseModel, bool isActiveCourse = true}) async {
    if (pageUserModel == null) return;

    if (context.checkMounted() && context.mounted) {
      dynamic newValue = await showDialog(
        context: context,
        builder: (context) {
          return AssignCourseValiditySelectionDialog(
            courseModel: courseModel,
          );
        },
      );
      MyPrint.printOnConsole("Got newValue:'$newValue'");

      if (newValue is! int) {
        return;
      }

      await assignCourse(
        courseModel: courseModel,
        validityDays: newValue,
        successMessage: isActiveCourse ? "Course Extended!" : "Course Reassigned!",
      );
    }
  }

  Future<void> assignCourse({required CourseModel courseModel, required int validityDays, String successMessage = ""}) async {
    MyPrint.printOnConsole("assignCourse called for CourseId:${courseModel.id}, validityDays:$validityDays");

    if (pageUserModel == null) {
      MyPrint.printOnConsole("Returning from assignCourse because pageUserModel is null");
      return;
    }

    isLoading = true;
    mySetState();

    bool isAssigned = await UserController(userProvider: null).assignCourse(
      userModel: pageUserModel!,
      courseId: courseModel.id,
      validityDays: validityDays,
      courseName: courseModel.title,
      courseImage: courseModel.thumbnailUrl,
    );

    if (isAssigned) {
      await getAssignedCourses(courseIds: pageUserModel!.myCoursesData.keys.toList());
    }

    isLoading = false;
    mySetState();

    if (isAssigned) {
      if (context.checkMounted() && context.mounted) {
        MyToast.showSuccess(context: context, msg: successMessage.isEmpty ? "Course Assigned!" : successMessage);
      }
    }
  }

  Future<void> expireCourse({required CourseModel courseModel}) async {
    MyPrint.printOnConsole("expireCourse called for CourseId:${courseModel.id}");

    if (pageUserModel == null) {
      MyPrint.printOnConsole("Returning from unAssignCourse because pageUserModel is null");
      return;
    }

    dynamic newValue = await showDialog(
      context: context,
      builder: (context) {
        return CommonPopup(
          text: "Are you sure want to expire this course?",
          leftText: "No",
          rightText: "Yes",
          rightOnTap: () {
            Navigator.pop(context, true);
          },
        );
      },
    );
    MyPrint.printOnConsole("Got newValue:'$newValue'");

    if (newValue != true) {
      return;
    }

    isLoading = true;
    mySetState();

    bool isUnAssigned = await UserController(userProvider: null).expireUserCourse(
      userModel: pageUserModel!,
      courseId: courseModel.id,
      courseName: courseModel.title,
      courseImage: courseModel.thumbnailUrl,
    );

    isLoading = false;
    mySetState();

    if (isUnAssigned) {
      if (context.checkMounted() && context.mounted) {
        MyToast.showSuccess(context: context, msg: "Course Expired!");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    userProvider = context.read<UserProvider>();
    userController = UserController(userProvider: userProvider);

    eventProvider = EventProvider();
    eventController = EventController(eventProvider: eventProvider);

    adminProvider = context.read<AdminProvider>();

    futureGetData = getUsersData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EventProvider>.value(value: eventProvider),
      ],
      child: FutureBuilder(
        future: futureGetData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const CommonProgressIndicator();
          }

          return Scaffold(
            backgroundColor: AppColor.bgColor,
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              progressIndicator: const Center(
                  child: CommonProgressIndicator(
                bgColor: Colors.transparent,
              )),
              child: Column(
                children: <Widget>[
                  HeaderWidget(title: 'Student Profile', isBackArrow: true),
                  const SizedBox(height: 20),
                  Expanded(
                    child: getMainBody(userModel: pageUserModel),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget getMainBody({UserModel? userModel}) {
    if (userModel == null) {
      return Center(
        child: CommonText(text: 'Issue in Fetching Student Info! Please try again'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        getUserProfileView(pageUserModel!),
        const SizedBox(height: 25),
        Expanded(child: getCoursesListMainWidget()),
      ],
    );
  }

  //region User Profile Info
  Widget getUserProfileView(UserModel userModel) {
    String birthDate = userModel.dateOfBirth == null ? 'Information Not Available' : DateFormat("dd-MMM-yyyy").format(userModel.dateOfBirth!.toDate());
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.white, border: Border.all(color: AppColor.bgSideMenu.withOpacity(.6), width: .5)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(150),
            child: CommonCachedNetworkImage(
              imageUrl: userModel.imageUrl,
              width: 80,
              height: 80,
              borderRadius: 150,
            ),
          ),
          const SizedBox(width: 20),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getCommonRichText(
                heading: 'Student Name',
                data: userModel.name,
              ),
              const SizedBox(height: 3),
              getCommonRichText(
                heading: 'Mobile Number',
                data: userModel.mobileNumber,
              ),
              const SizedBox(height: 3),
              getCommonRichText(
                heading: 'Date of Birth',
                data: '$birthDate(${userModel.age} years)',
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getCommonRichText({required String heading, required String data, double fontSize = 16}) {
    return RichText(
      text: TextSpan(text: "$heading : ", style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: AppColor.bgSideMenu), children: [
        TextSpan(
          text: data,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.normal,
            color: AppColor.bgSideMenu,
          ),
        )
      ]),
    );
  }

  //endregion

  //region User Courses List
  Widget getCoursesListMainWidget() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GetTitle(title: 'Assigned Courses', fontSize: 20),
            CommonButton(
              onTap: () {
              },
              text: '+  Assign Course',
            )
          ],
        ),
        const SizedBox(height: 20),
        Expanded(child: getCourseList()),
      ],
    );
  }

  Widget getCourseList() {
    return Consumer(
      builder: (BuildContext context, EventProvider courseProvider, Widget? child) {
        List<EventModel> courses = courseProvider.events.getList(isNewInstance: false);

        if (courses.isEmpty) {
          return Center(
            child: CommonText(
              text: "No Courses Available",
              fontWeight: FontWeight.normal,
              fontSize: 18,
            ),
          );
        }

        //List<NewsFeedModel> newsList = newsProvider.newsList;
        return ListView.builder(
          itemCount: courses.length,
          //shrinkWrap: true,
          itemBuilder: (context, index) {
            EventModel courseModel = courses[index];
            return singleCourse(courseModel, index);
          },
        );
      },
    );
  }

  Widget singleCourse(EventModel courseModel, int index) {
    UserCourseEnrollmentModel? userCourseEnrollmentModel = pageUserModel?.myCoursesData[courseModel.id];

    bool isActive = pageUserModel?.checkIsActiveCourse(courseId: courseModel.id, now: adminProvider.timeStamp.get()?.toDate()) ?? false;
    int daysRemaining = 0;
    if(userCourseEnrollmentModel?.activatedDate != null && userCourseEnrollmentModel?.expiryDate != null) {
      daysRemaining = userCourseEnrollmentModel!.expiryDate!.toDate().difference(userCourseEnrollmentModel.activatedDate!.toDate()).inDays;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
        onTap: () {},
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
                child: CommonCachedNetworkImage(
                  imageUrl: courseModel.imageUrl,
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
                      text: courseModel.title,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: courseModel.description,
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text:
                          'Assigned Date: ${userCourseEnrollmentModel?.activatedDate == null ? "No Data" : DateFormat("dd-MMM-yyyy").format(userCourseEnrollmentModel!.activatedDate!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text:
                          'Expiry Date: ${userCourseEnrollmentModel?.expiryDate == null ? "No Data" : DateFormat("dd-MMM-yyyy").format(userCourseEnrollmentModel!.expiryDate!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          child: CommonButton(
                            onTap: () {
                              // extendValidityOfCourseOnTap(
                              //   courseModel: courseModel,
                              //   isActiveCourse: isActive,
                              // );
                            },
                            text: isActive ? "Extend Validity" : "Reassign Course",
                            verticalPadding: 5,
                            horizontalPadding: 5,
                            fontSize: 13,
                          ),
                        ),
                        if (isActive)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            child: CommonButton(
                              onTap: () {
                                // expireCourse(
                                //   courseModel: courseModel,
                                // );
                              },
                              text: "Expire Course",
                              verticalPadding: 5,
                              horizontalPadding: 5,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              getActiveExpiredWidget(isActive: isActive, daysRemaining: daysRemaining),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget getActiveExpiredWidget({required bool isActive, required int daysRemaining}) {
    if (isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$daysRemaining Days Remaining",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(5),
            ),
            child: const Text(
              "Active",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Text(
          "Expired",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      );
    }
  }
//endregion
}
