import 'package:baroda_chest_group_admin/backend/committee_member/committee_member_controller.dart';
import 'package:baroda_chest_group_admin/backend/member/member_controller.dart';
import 'package:baroda_chest_group_admin/backend/member/member_provider.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/committee_member/committee_member_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/constants.dart';
import '../../../models/profile/data_model/committee_member_model.dart';
import '../../../models/profile/data_model/member_model.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class CommitteeMemberScreenNavigator extends StatefulWidget {
  const CommitteeMemberScreenNavigator({Key? key}) : super(key: key);

  @override
  _CommitteeMemberScreenNavigatorState createState() => _CommitteeMemberScreenNavigatorState();
}

class _CommitteeMemberScreenNavigatorState extends State<CommitteeMemberScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.committeeMemberScreenNavigator,
      onGenerateRoute: NavigationController.onCommitteeMemberGeneratedRoutes,
    );
  }
}

class CommitteeMemberScreen extends StatefulWidget {
  const CommitteeMemberScreen({super.key});

  @override
  State<CommitteeMemberScreen> createState() => _CommitteeMemberScreenState();
}

class _CommitteeMemberScreenState extends State<CommitteeMemberScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late CommitteeMemberProvider committeeMemberProvider;
  late CommitteeMemberController committeeMemberController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await committeeMemberController.getCommitteeMemberPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    committeeMemberProvider = Provider.of<CommitteeMemberProvider>(context, listen: false);
    committeeMemberController = CommitteeMemberController(committeeMemberProvider: committeeMemberProvider);

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
              title: "Committee Member",
              suffixWidget: CommonButton(
                text: "Add Committee Member",
                icon: Icon(
                  Icons.add,
                  color: AppColor.white,
                ),
                onTap: () async {
                  await NavigationController.navigateToAddCommitteeMemberScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        navigationType: NavigationType.pushNamed,
                        context: context,
                      ),
                      addMemberScreenNavigationArguments: AddCommitteeMemberScreenNavigationArguments());
                  // getData(
                  //   isRefresh: true,
                  //   isFromCache: false,
                  //   isNotify: true,
                  // );
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
    return Consumer(builder: (BuildContext context, CommitteeMemberProvider memberProvider, Widget? child) {
      if (memberProvider.isCommitteeMemberFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!memberProvider.isCommitteeMemberLoading.get() && memberProvider.allCommitteeMemberLength == 0) {
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
                    child: Text("No CommitteeMember"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<CommitteeMemberModel> member = memberProvider.committeeMemberList.getList(isNewInstance: false);

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
              if (memberProvider.isCommitteeMemberLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (memberProvider.hasMoreCommitteeMember.get() && index > (member.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                committeeMemberController.getCommitteeMemberPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            CommitteeMemberModel model = member[index];

            // MyPrint.printOnConsole("Member Model: ${model.toMap()}");

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(CommitteeMemberModel memberModel, int index, BuildContext topContext) {
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
                  await NavigationController.navigateToAddCommitteeMemberScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      navigationType: NavigationType.pushNamed,
                      context: topContext,
                    ),
                    addMemberScreenNavigationArguments: AddCommitteeMemberScreenNavigationArguments(
                      committeeMemberModel: memberModel,
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  imageUrl: memberModel.profileUrl,
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
                      text: memberModel.name,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 10),
                    CommonText(
                      text: memberModel.type,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(
                      height: 10,
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
}
