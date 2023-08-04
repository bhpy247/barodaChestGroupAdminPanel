import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/models/user/data_model/user_course_enrollment_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/users_backend/user_controller.dart';
import '../../../backend/users_backend/user_provider.dart';
import '../../../configs/constants.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/table/my_table_cell_model.dart';
import '../../common/components/table/my_table_row_widget.dart';

class UserScreenNavigator extends StatefulWidget {
  const UserScreenNavigator({Key? key}) : super(key: key);

  @override
  _UserScreenNavigatorState createState() => _UserScreenNavigatorState();
}

class _UserScreenNavigatorState extends State<UserScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.userScreenNavigator,
      onGenerateRoute: NavigationController.onUserGeneratedRoutes,
    );
  }
}

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> with MySafeState {
  late UserProvider userProvider;
  late UserController userController;

  List<int> flexes = [
    1,
    1,
    1,
    1,
  ];
  List<String> titles = [
    "Sr No.",
    "Name",
    "Mobile",
    "Courses",
  ];
  late Future<void> futureGetData;

  TextEditingController searchController = TextEditingController();

  Future<void> getUsersData() async {
    await userController.getAllUsersFromFirebase(isNotify: false);
  }

  @override
  void initState() {
    super.initState();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    userController = UserController(userProvider: userProvider);

    futureGetData = getUsersData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return FutureBuilder(
      future: futureGetData,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: AppColor.bgColor,
            body: Column(
              children: [
                HeaderWidget(
                  title: "Users",
                  suffixWidget: getUserSearchBar(),
                ),
                const SizedBox(height: 10),
                MyTableRowWidget(
                  backgroundColor: AppColor.bgSideMenu,
                  cells: [
                    ...List.generate(titles.length, (index) {
                      return MyTableCellModel(
                          flex: flexes[index],
                          child: CommonText(
                            text: titles[index],
                            color: AppColor.white,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ));
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: getUsersList(context),
                ),
              ],
            ),
          );
        } else {
          return const CommonProgressIndicator();
        }
      },
    );
  }

  Widget getUserSearchBar() {
    return SizedBox(
      width: 500,
      child: CommonTextFormField(
        controller: searchController,
        hintText: "Enter User Mobile OR Name",
        prefixIcon: const Icon(
          Icons.search,
          color: Colors.black,
        ),
        onChanged: (String text) {
          mySetState();
        },
        suffixIcon: searchController.text.isNotEmpty ? GestureDetector(
          onTap: () {
            searchController.clear();
            mySetState();
          },
          child: const Icon(
            Icons.close,
            color: Colors.black,
          ),
        ) : null,
      ),
    );
  }

  Widget getUsersList(BuildContext topContext) {
    return Consumer(builder: (BuildContext context, UserProvider userProvider, Widget? child) {
      List<UserModel> users = userProvider.usersList;
      String searchText = searchController.text.trim().toLowerCase();

      if (users.isEmpty) {
        return Center(
          child: CommonText(
            text: "No Users Available",
            fontWeight: FontWeight.bold,
          ),
        );
      }

      int userIndex = -1;

      //List<NewsFeedModel> newsList = newsProvider.newsList;
      return ListView.builder(
        itemCount: users.length + 1,
        //shrinkWrap: true,
        itemBuilder: (context, index) {
          if ((index == 0 && users.isEmpty) || (index == users.length)) {
            if (userProvider.getIsUsersLoading) {
              return Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.bgColor,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(child: CircularProgressIndicator(color: AppColor.bgSideMenu)),
              );
            } else {
              return const SizedBox();
            }
          }

          if (userProvider.getHasMoreUsers && index > (users.length - AppConstants.userRefreshIndexForPagination)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              MyPrint.printOnConsole("Ye wali Method call");
              userController.getAllUsersFromFirebase(isRefresh: false, isNotify: false);
            });
          }

          UserModel userModel = users[index];

          if (searchText.isEmpty ||
              (userModel.mobileNumber.toLowerCase().trim().contains(searchText) || userModel.name.toLowerCase().trim().contains(searchText))) {
            userIndex++;
            return singleUser(userModel, userIndex, topContext);
          }
          return const SizedBox();
        },
      );
    });
  }

  Widget singleUser(UserModel userModel, int index, BuildContext topContext) {
    Map<String, UserCourseEnrollmentModel> myCoursesData = userModel.myCoursesData;
    DateTime now = DateTime.now();

    int activeCoursesLength = myCoursesData.keys.where((String courseId) {
      return userModel.checkIsActiveCourse(courseId: courseId, now: now);
    }).length;
    int expiredCoursesLength = myCoursesData.length - activeCoursesLength;

    return InkWell(
      onTap: () async {
        await NavigationController.navigateToUserProfileViewScreen(
          navigationOperationParameters: NavigationOperationParameters(
            navigationType: NavigationType.pushNamed,
            context: topContext,
          ),
          userProfileViewScreenNavigationArguments: UserProfileViewScreenNavigationArguments(
            userId: userModel.id,
            userModel: userModel,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
        child: MyTableRowWidget(
          backgroundColor: Colors.white,
          cells: [
            MyTableCellModel(
              flex: flexes[0],
              child: CommonText(
                text: "${index + 1}",
                textAlign: TextAlign.center,
              ),
            ),
            MyTableCellModel(
              flex: flexes[1],
              child: CommonText(
                text: userModel.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                textOverFlow: TextOverflow.ellipsis,
              ),
            ),
            MyTableCellModel(
              flex: flexes[2],
              child: CommonText(
                text: userModel.mobileNumber,
                textAlign: TextAlign.center,
                maxLines: 2,
                textOverFlow: TextOverflow.ellipsis,
              ),
            ),
            MyTableCellModel(
              flex: flexes[3],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: getCourseEnrollmentWidget(
                      count: activeCoursesLength,
                      isActive: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: getCourseEnrollmentWidget(
                      count: expiredCoursesLength,
                      isActive: false,
                    ),
                  ),
                ],
              ),
            ),

            // MyTableCellModel(
            //   flex: flexes[5],
            //   child: getTestEnableSwitch(
            //       value: userModel.adminEnabled,
            //       onChanged: (val) {
            //         Map<String,dynamic> data = {
            //           "adminEnabled" : val,
            //         };
            //         userController.EnableDisableUserInFirebase(editableData: data, id: userModel.id,listIndex:index);
            //       }
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget getCourseEnrollmentWidget({required int count, bool isActive = true}) {
    Color color;
    IconData iconData;
    String text = "";

    Color activeColor = const Color(0xff5AA151);
    Color expiryColor = Colors.red;

    if (isActive) {
      color = activeColor;
      iconData = Icons.timelapse;
      text = "Active Courses $count";
    } else {
      color = expiryColor;
      iconData = Icons.running_with_errors;
      text = "Expired Courses $count";
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: CommonText(
              text: text,
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget getTestEnableSwitch({required bool value, void Function(bool?)? onChanged}) {
    return CupertinoSwitch(
      value: value,
      onChanged: onChanged,
      activeColor: AppColor.bgSideMenu,
    );
  }
}
