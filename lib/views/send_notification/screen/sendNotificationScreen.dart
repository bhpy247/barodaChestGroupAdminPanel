import 'package:baroda_chest_group_admin/backend/notification/notification_controller.dart';
import 'package:baroda_chest_group_admin/configs/constants.dart';
import 'package:baroda_chest_group_admin/models/common/data_model/notification_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/utils/my_utils.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_button.dart';
import 'package:flutter/material.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/get_title.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class SendNotificationScreenNavigator extends StatefulWidget {
  const SendNotificationScreenNavigator({Key? key}) : super(key: key);

  @override
  _SendNotificationScreenNavigatorState createState() => _SendNotificationScreenNavigatorState();
}

class _SendNotificationScreenNavigatorState extends State<SendNotificationScreenNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavigationController.sendNotificationScreenNavigator,
      onGenerateRoute: NavigationController.onSendNotificationScreenRoutes,
    );
  }
}

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> with MySafeState {
  bool isLoading = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> sendNotification() async {
    isLoading = true;
    mySetState();

    await NotificationController.sendNotificationMessage2(
      topic: NotificationTopicType.admin,
      description: descriptionController.text.trim(),
      title: titleController.text.trim(),
      data: <String, dynamic>{
        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        'id': '1',
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'type': NotificationTypes.news,
      },
    );
    NotificationModel noficationModel =
        NotificationModel(description: descriptionController.text.trim(), title: titleController.text.trim(), notificationType: NotificationTypes.news, id: MyUtils.getNewId());
    await NotificationController().addNotificationToFirebase(noficationModel);

    isLoading = false;
    mySetState();
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
              title: "Flash News",
            ),
            const SizedBox(height: 20),
            getMainBody()
          ],
        ),
      ),
    );
  }

  Widget getMainBody() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            getTitle(),
            SizedBox(
              height: 10,
            ),
            getDescription(),
            SizedBox(
              height: 10,
            ),
            CommonButton(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    sendNotification();
                  }
                },
                text: "Send")
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Event Title*"),
              CommonTextFormField(
                controller: titleController,
                hintText: "Enter Title",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Title";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getDescription() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Description*"),
              CommonTextFormField(
                controller: descriptionController,
                hintText: "Enter Description",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Description";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
