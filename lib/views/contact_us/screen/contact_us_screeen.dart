import 'package:baroda_chest_group_admin/models/profile/data_model/contact_us_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/contact_us/contact_us_controller.dart';
import '../../../backend/contact_us/contact_us_provider.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../configs/constants.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class ContactUsScreenNavigator extends StatefulWidget {
  const ContactUsScreenNavigator({Key? key}) : super(key: key);

  @override
  _ContactUsScreenNavigatorState createState() => _ContactUsScreenNavigatorState();
}

class _ContactUsScreenNavigatorState extends State<ContactUsScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.contactUsScreenNavigator,
      onGenerateRoute: NavigationController.onContactUsScreenRoutes,
    );
  }
}

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> with MySafeState{
  ScrollController scrollController = ScrollController();
  bool isLoading = false;

  late ContactUsProvider contactUsProvider;
  late ContactUsController contactUsController;

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await contactUsController.getContactUsPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();
    contactUsProvider = Provider.of<ContactUsProvider>(context, listen: false);
    contactUsController = ContactUsController(contactUsProvider: contactUsProvider);

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
              title: "Feedback",
            ),
            const SizedBox(height: 20),
            Expanded(child: getMemberList(topContext: context)),
          ],
        ),
      ),
    );
  }

  Widget getMemberList({required BuildContext topContext}) {
    return Consumer(builder: (BuildContext context, ContactUsProvider contactUsProvider, Widget? child) {
      if (contactUsProvider.isContactUsFirstTimeLoading.get()) {
        return const Center(child: CommonProgressIndicator());
      }

      if (!contactUsProvider.isContactUsLoading.get() && contactUsProvider.allContactUsLength == 0) {
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
                    child: Text("No ContactUs"),
                  ),
                ],
              ),
            );
          },
        );
      }

      List<ContactUsModel> member = contactUsProvider.contactUsList.getList(isNewInstance: false);

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
              if (contactUsProvider.isContactUsLoading.get()) {
                // if(true) {
                return const CommonProgressIndicator();
              } else {
                return const SizedBox();
              }
            }

            if (contactUsProvider.hasMoreContactUs.get() && index > (member.length - AppConstants.coursesRefreshLimitForPagination)) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                contactUsController.getContactUsPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
              });
            }

            ContactUsModel model = member[index];

            // MyPrint.printOnConsole("Member Model: ${model.toMap()}");

            return singleCourse(model, index, topContext);
          },
        ),
      );
    });
  }

  Widget singleCourse(ContactUsModel memberModel, int index, BuildContext topContext) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.white,
          border: Border.all(color: AppColor.yellow, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Container(
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
              ),const SizedBox(height: 10),
              CommonText(
                text: memberModel.message,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
