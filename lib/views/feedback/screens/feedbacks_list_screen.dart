import 'package:baroda_chest_group_admin/utils/my_utils.dart';
import 'package:baroda_chest_group_admin/views/common/components/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../backend/admin/admin_controller.dart';
import '../../../backend/admin/admin_provider.dart';
import '../../../models/other/data_model/feedback_model.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_safe_state.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/header_widget.dart';

class FeedbacksListScreen extends StatefulWidget {
  const FeedbacksListScreen({super.key});

  @override
  _FeedbacksListScreenState createState() => _FeedbacksListScreenState();
}

class _FeedbacksListScreenState extends State<FeedbacksListScreen> with MySafeState {
  late Future<List<FeedbackModel>> future;

  late AdminProvider adminProvider;
  late AdminController adminController;

  Future<void>? futureGetData;

  List<FeedbackModel> feedbacksList = [];
  bool isLoading = false;

  Future<void> getFeedbacksData({List<FeedbackModel>? feedbacks, bool isRefresh = true}) async {
    feedbacks ??= await adminController.getFeedbacks(isRefresh: isRefresh);

    feedbacksList = feedbacks;

    mySetState();
  }

  Future getFeedbacksFromDatabase({bool isRefresh = true}) async {
    isLoading = true;
    mySetState();

    try {
      feedbacksList = await adminController.getFeedbacks(isRefresh: isRefresh);
    } catch (e) {
      MyPrint.printOnConsole("Error in FeedbacksListScreen.getFeedbacksFromDatabase:$e");
      isLoading = false;
      feedbacksList.clear();
    }

    isLoading = false;
    mySetState();
  }

  void deleteFeedback(String feedbackid) async {
    dynamic value = await showDialog(
      context: context,
      builder: (context) {
        return CommonPopup(
          text: "Are you sure want to delete this feedback?",
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

    bool isDeleted = await adminController.deleteFeedback(feedbackid);

    isLoading = false;
    mySetState();

    if (isDeleted) {
      showSimpleSnackbar("Deleted");

      getFeedbacksFromDatabase();
    } else {
      showSimpleSnackbar("Error in Deleting Feedback");
    }
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

  @override
  void initState() {
    super.initState();

    adminProvider = context.read<AdminProvider>();
    adminController = AdminController(adminProvider: adminProvider);

    if (adminProvider.faqList.length > 0) {
      getFeedbacksData(feedbacks: adminProvider.feedbackList.getList());
    } else {
      futureGetData = getFeedbacksData(isRefresh: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Scaffold(
      // backgroundColor: themeData.colorScheme.background,
      body: Column(
        children: [
          HeaderWidget(
            title: "Feedbacks",
          ),
          Expanded(
            child: futureGetData != null
                ? FutureBuilder<void>(
                    future: futureGetData,
                    builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const LoadingWidget(
                          isCenter: true,
                        );
                      }

                      return getFeedbacksListViewWidget();
                    },
                  )
                : getFeedbacksListViewWidget(),
          ),
        ],
      ),
    );
  }

  Widget getFeedbacksListViewWidget() {
    MyPrint.printOnConsole("feedbacksList length:${feedbacksList.length}");

    if (feedbacksList.isEmpty) {
      return const Center(
        child: Text("No Feedbacks available"),
      );
    }

    return ListView.builder(
      itemCount: feedbacksList.length,
      itemBuilder: (BuildContext context, int index) {
        FeedbackModel feedbackModel = feedbacksList[index];

        return getFeedbackCardWidget(feedbackModel: feedbackModel);
      },
    );
  }

  Widget getFeedbackCardWidget({required FeedbackModel feedbackModel}) {
    String formattedDate = "", createdAtTime = "";

    if (feedbackModel.createdTime != null) {
      DateTime date = feedbackModel.createdTime!.toDate();
      DateTime current = DateTime.now();
      if (date.year == current.year && date.month == current.month && date.day == current.day) {
        formattedDate = "Today";
      } else {
        formattedDate = DateFormat('dd MMM , yyyy').format(feedbackModel.createdTime!.toDate());
      }

      createdAtTime = DateFormat('hh:mm:ss aa').format(feedbackModel.createdTime!.toDate());
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0), topRight: Radius.circular(8.0)),
          boxShadow: <BoxShadow>[
            BoxShadow(color: Colors.grey.withOpacity(0.2), offset: const Offset(1.1, 1.1), blurRadius: 10.0),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      feedbackModel.type,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  /*Icon(
                    Icons.notifications,
                    size: 18,
                    color: themeData.colorScheme.primary,
                  )*/
                ],
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                child: Container(
                  color: Colors.black26,
                  height: 0.5,
                )),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description : \n${feedbackModel.description}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Rating : ${feedbackModel.rating}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    "User Name : ${feedbackModel.userName}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 15, bottom: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      if (feedbackModel.mobile.isNotEmpty) MyUtils.launchCallMobileNumber(mobileNumber: feedbackModel.mobile);
                    },
                    child: const Text(
                      "CALL",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: -0.2,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () async {
                      deleteFeedback(feedbackModel.id);
                    },
                    child: const Text(
                      "DELETE",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: -0.2,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "$formattedDate | $createdAtTime",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
