import 'package:baroda_chest_group_admin/backend/membership_form/membership_form_controller.dart';
import 'package:baroda_chest_group_admin/backend/membership_form/membership_form_provider.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/membership_model.dart';
import 'package:baroda_chest_group_admin/utils/date_presentation.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../configs/constants.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class MembershipFormScreenNavigator extends StatefulWidget {
  const MembershipFormScreenNavigator({Key? key}) : super(key: key);

  @override
  _MembershipFormScreenNavigatorState createState() => _MembershipFormScreenNavigatorState();
}

class _MembershipFormScreenNavigatorState extends State<MembershipFormScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.membershipScreenNavigator,
      onGenerateRoute: NavigationController.onMembershipFormScreenRoutes,
    );
  }
}

class MembershipFormScreen extends StatefulWidget {
  const MembershipFormScreen({super.key});

  @override
  State<MembershipFormScreen> createState() => _MembershipFormScreenState();
}

class _MembershipFormScreenState extends State<MembershipFormScreen> with MySafeState {
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late MembershipFormProvider membershipFormProvider;
  late MembershipFormController membershipFromController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await membershipFromController.getMembershipFormPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    membershipFormProvider = Provider.of<MembershipFormProvider>(context, listen: false);
    membershipFromController = MembershipFormController(membershipProvider: membershipFormProvider);

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
              title: "Membership Requests",
            ),
            const SizedBox(height: 20),
            Expanded(child: getMemberList(topContext: context)),
          ],
        ),
      ),
    );
  }

  Widget getMemberList({required BuildContext topContext}) {
    return Consumer(builder: (BuildContext context, MembershipFormProvider contactUsProvider, Widget? child) {
      if (contactUsProvider.isMembershipFormFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!contactUsProvider.isMembershipFormLoading.get() && contactUsProvider.allMembershipFormLength == 0) {
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
                    child: Text("No Membership Form Request"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<MembershipModel> member = contactUsProvider.membershipFormList.getList(isNewInstance: false);

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
              if (contactUsProvider.isMembershipFormLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (contactUsProvider.hasMoreMembershipForm.get() && index > (member.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                membershipFromController.getMembershipFormPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            MembershipModel model = member[index];

            // MyPrint.printOnConsole("Member Model: ${model.toMap()}");

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(MembershipModel memberModel, int index, BuildContext topContext) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.yellow, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getRichText(textHeader: "Name", text: memberModel.name),
              getRichText(textHeader: "Email", text: memberModel.email),
              getRichText(textHeader: "Qualification", text: memberModel.qualification),
              getRichText(textHeader: "References", text: memberModel.reference),
              getRichText(textHeader: "Age", text: memberModel.age.toString()),
              getRichText(textHeader: "Mobile", text: memberModel.mobile.toString()),
              getRichText(textHeader: "Why Want To Be Member", text: memberModel.whyWantToBeMember),
              if (memberModel.createdTime != null) getRichText(textHeader: "Request Date", text: DatePresentation.ddMMMMyyyyTimeStamp(memberModel.createdTime!)),

              // CommonText(
              //   text: memberModel.name,
              //   fontSize: 20,
              //   fontWeight: FontWeight.bold,
              // ),
              // const SizedBox(height: 10),
              // CommonText(
              //   text: memberModel.email,
              //   fontSize: 16,
              //   fontWeight: FontWeight.w500,
              // ),
              // const SizedBox(height: 10),
              // CommonText(
              //   text: memberModel.whyWantToBeMember,
              //   fontSize: 16,
              //   fontWeight: FontWeight.w500,
              // ),
              // CommonText(
              //   text: memberModel.qualification,
              //   fontSize: 16,
              //   fontWeight: FontWeight.w500,
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getRichText({String textHeader = "", String text = ""}) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text.rich(
        TextSpan(
          text: "${textHeader}: ",
          children: [
            TextSpan(
              text: text,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
