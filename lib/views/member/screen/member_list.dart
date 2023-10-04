import 'package:baroda_chest_group_admin/backend/member/member_controller.dart';
import 'package:baroda_chest_group_admin/backend/member/member_provider.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/utils/my_print.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/brochure/brochure_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../models/profile/data_model/member_model.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class MemberScreenNavigator extends StatefulWidget {
  const MemberScreenNavigator({Key? key}) : super(key: key);

  @override
  _MemberScreenNavigatorState createState() => _MemberScreenNavigatorState();
}

class _MemberScreenNavigatorState extends State<MemberScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.memberScreenNavigator,
      onGenerateRoute: NavigationController.onMemberGeneratedRoutes,
    );
  }
}

class MemberScreen extends StatefulWidget {
  const MemberScreen({super.key});

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late MemberProvider memberProvider;
  late MemberController memberController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await memberController.getMemberPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  void showSimpleSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 1000),
        content: Text(
          message,
          style: themeData.textTheme.titleSmall?.merge(TextStyle(color: themeData.colorScheme.onPrimary)),
        ),
        backgroundColor: themeData.colorScheme.primary,
      ),
    );
  }

  Future<void> deleteEvent(MemberModel memberModel) async {
    if (memberModel.id.isEmpty) {
      return;
    }

    dynamic value = await showDialog(
      context: context,
      builder: (context) {
        return CommonPopup(
          text: "Are you sure want to delete this Event?",
          leftText: "Cancel",
          rightText: "Delete",
          rightOnTap: () {
            Navigator.pop(context, true);
          },
          rightBackgroundColor: Colors.red,
        );
      },
    );

    if (value != true) {
      return;
    }

    isLoading = true;
    mySetState();

    bool isDeleted = await FirebaseNodes.memberDocumentReference(docId: memberModel.id).delete().then((value) {
      return true;
    }).catchError((e, s) {
      MyPrint.printOnConsole("Error in Deleting Member:$e");
      MyPrint.printOnConsole(s);

      return false;
    });

    isLoading = false;
    if (isDeleted) {
      memberProvider.memberList.getList().remove(memberModel);
    }

    mySetState();

    if (isDeleted) {
      showSimpleSnackbar("Deleted");
    } else {
      showSimpleSnackbar("Error in Deleting Member");
    }
  }

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    memberController = MemberController(memberProvider: memberProvider);

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
              title: "Member",
              suffixWidget: CommonButton(
                text: "Add Member",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddMemberScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addMemberScreenNavigationArguments: AddMemberScreenNavigationArguments());
                  getData(
                    isRefresh: true,
                    isFromCache: false,
                    isNotify: true,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: getMemberList(topContext: context)),
          ],
        ),
      ),
    );
  }

  Widget getMemberList({required BuildContext topContext}) {
    return Consumer(builder: (BuildContext context, MemberProvider memberProvider, Widget? child) {
      if (memberProvider.isMemberFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!memberProvider.isMemberLoading.get() && memberProvider.allMemberLength == 0) {
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
                    child: Text("No Member"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<MemberModel> member = memberProvider.memberList.getList(isNewInstance: false);

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
          itemCount: member.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if ((index == 0 && member.isEmpty) || (index == member.length)) {
              if (memberProvider.isMemberLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (memberProvider.hasMoreMember.get() && index > (member.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                memberController.getMemberPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            MemberModel model = member[index];

            // MyPrint.printOnConsole("Member Model: ${model.toMap()}");

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(MemberModel memberModel, int index, BuildContext topContext) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Want to Edit member?",
                rightText: "Yes",
                rightOnTap: () async {
                  Navigator.pop(context);
                  await NavigationController.navigateToAddMemberScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addMemberScreenNavigationArguments: AddMemberScreenNavigationArguments(
                      memberModel: memberModel,
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
                      text: memberModel.name,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: memberModel.email,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: memberModel.designation,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: memberModel.address,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    if(memberModel.address.isNotEmpty)
                    const SizedBox(height: 10),
                    CommonText(
                      text: memberModel.createdTime == null ? 'Created Date: No Data' : 'Created Date: ${DateFormat("dd-MMM-yyyy").format(memberModel.createdTime!.toDate())}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      textOverFlow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () async {
                  await deleteEvent(memberModel);
                  getData(
                    isRefresh: true,
                    isFromCache: false,
                    isNotify: false,
                  );
                },
                child: const Icon(Icons.delete),
              )
            ],
          ),
        ),
      ),
    );
  }
}
