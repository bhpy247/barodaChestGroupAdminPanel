import 'dart:typed_data';

import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../backend/common/firebase_storage_controller.dart';
import '../../../backend/guide_line/guideline_controller.dart';
import '../../../backend/guide_line/guideline_provider.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../models/profile/data_model/guideline_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_image_view_box.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/get_title.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class AddGuideline extends StatefulWidget {
  static const String routeName = "/addguideline";
  final AddGuidelineNavigationArguments arguments;

  const AddGuideline({super.key, required this.arguments});

  @override
  State<AddGuideline> createState() => _AddGuidelineState();
}

class _AddGuidelineState extends State<AddGuideline> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isCourseEnabled = true;

  late Future<void> futureGetData;
  late GuidelineProvider guidelineProvider;
  late GuidelineController guidelineController;
  DateTime? eventStartDate, eventEndDate;

  TextEditingController eventGuidelineNameController = TextEditingController();
  TextEditingController googleDriveUrlController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();

  GuidelineModel? pageCourseModel;

  Future<void> getData() async {
    if (widget.arguments.guidelineModel != null) {
      pageCourseModel = widget.arguments.guidelineModel;
    }

    if (pageCourseModel != null) {
      eventGuidelineNameController.text = pageCourseModel!.name;
      googleDriveUrlController.text = pageCourseModel!.downloadUrl;
    }
  }

  Future<void> addGuidelineToFirebase() async {
    setState(() {
      isLoading = true;
    });

    String courseId = pageCourseModel?.id ?? "";
    if (courseId.isEmpty) {
      courseId = MyUtils.getNewId(isFromUUuid: false);
    }

    GuidelineModel guidelineModel = GuidelineModel(
      id: courseId.trim(),
      name: eventGuidelineNameController.text.trim(),
      downloadUrl: googleDriveUrlController.text.trim(),
      createdTime: pageCourseModel?.createdTime ?? Timestamp.now(),
    );

    await guidelineController.addGuidelineToFirebase(
      guideline: guidelineModel,
      isAdInProvider: pageCourseModel == null,
    );
    MyPrint.printOnConsole('Added guideline Model is ${guidelineModel.toMap()}');

    if (pageCourseModel != null) {
      GuidelineModel model = pageCourseModel!;
      model.name = guidelineModel.name;
      model.downloadUrl = guidelineModel.downloadUrl;
      model.createdTime = guidelineModel.createdTime;
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageCourseModel == null ? 'Guideline Added Successfully' : 'Guideline Edited Successfully');
    }
  }

  @override
  void initState() {
    super.initState();
    guidelineProvider = Provider.of<GuidelineProvider>(context, listen: false);
    guidelineController = GuidelineController(guidelineProvider: guidelineProvider);
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    MyPrint.printOnConsole("pageCourseModel?.id:${pageCourseModel?.id}");

    return FutureBuilder(
      future: futureGetData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: AppColor.bgColor,
            body: ModalProgressHUD(
              inAsyncCall: isLoading,
              progressIndicator: const CommonProgressIndicator(),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    HeaderWidget(title: pageCourseModel == null ? "Add Guideline" : "Edit Guideline", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getGuidelineName(),
                            const SizedBox(height: 20),
                            getDownloadUrlField(),
                            const SizedBox(height: 30),
                            submitButton(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          return const CommonProgressIndicator();
        }
      },
    );
  }

  Widget getGuidelineName() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Enter Guideline Name*"),
        CommonTextFormField(
          controller: eventGuidelineNameController,
          hintText: "Enter Guideline Name",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "  Please enter Guideline Name";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget getDownloadUrlField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Enter Google drive url"),
        CommonTextFormField(
          controller: googleDriveUrlController,
          hintText: "Enter Google Drive Url",
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "  Please enter Google Drive Url";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget submitButton() {
    return CommonButton(
      onTap: () async {
        if (_formKey.currentState!.validate()) {

          dynamic newValue = await showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Are you sure want to ${pageCourseModel == null ? "Add" : "Edit"} this guideline?",
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

          await addGuidelineToFirebase();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageCourseModel == null ? '+   Add Guideline ' : '+   Edit Guideline',
      fontSize: 17,
    );
  }
}
