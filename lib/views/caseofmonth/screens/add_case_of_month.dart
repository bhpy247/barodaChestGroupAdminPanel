import 'dart:typed_data';

import 'package:baroda_chest_group_admin/backend/case_of_month/case_of_month_provider.dart';
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../backend/case_of_month/case_of_month_controller.dart';
import '../../../backend/common/firebase_storage_controller.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/date_presentation.dart';
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

class AddCaseOfMonthScreen extends StatefulWidget {
  static const String routeName = "/addcaseofmonth";
  final AddCaseOfMonthScreenNavigationArguments arguments;

  const AddCaseOfMonthScreen({super.key, required this.arguments});

  @override
  State<AddCaseOfMonthScreen> createState() => _AddCaseOfMonthScreenState();
}

class _AddCaseOfMonthScreenState extends State<AddCaseOfMonthScreen> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isCourseEnabled = true;

  late Future<void> futureGetData;
  late CaseOfMonthProvider caseOfMonthProvider;
  late CaseOfMonthController caseOfMonthController;
  DateTime? eventStartDate, eventEndDate;

  TextEditingController eventCaseNameController = TextEditingController();
  TextEditingController googleDriveUrlController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();

  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  String? thumbnailImageName;

  CaseOfMonthModel? pageCourseModel;

  Future<void> getData() async {
    if (widget.arguments.caseOfMonthModel != null) {
      pageCourseModel = widget.arguments.caseOfMonthModel;
    }

    if (pageCourseModel != null) {
      eventCaseNameController.text = pageCourseModel!.caseName;
      eventDescriptionController.text = pageCourseModel!.description;
      thumbnailImageUrl = pageCourseModel!.image;
      googleDriveUrlController.text = pageCourseModel!.downloadUrl;
    }
  }

  Future<void> addThumbnailImage() async {
    setState(() {});
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      String path = pickedFile.path;
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        compressFormat: ImageCompressFormat.jpg,
        sourcePath: path,
        aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
        cropStyle: CropStyle.rectangle,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColor.bgSideMenu,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            minimumAspectRatio: 1.0,
            aspectRatioLockEnabled: true,
            aspectRatioPickerButtonHidden: true,
          ),
          // ignore: use_build_context_synchronously
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 530,
              height: 330,
            ),
            viewPort: const CroppieViewPort(width: 400, height: 225, type: 'rectangular'),
            enableOrientation: true,
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );
      if (croppedFile != null) {
        thumbnailImage = await croppedFile.readAsBytes();
      }
      thumbnailImageName = pickedFile.name;

      if (mounted) setState(() {});
    }
  }

  Future<String?> uploadFileToFirebaseStorage({
    required String courseId,
    required String imageName,
  }) async {
    String? firebaseStorageImageUrl;
    String finalFileName = MyUtils().getStorageUploadImageUrl(nativeImageName: imageName);
    if (thumbnailImage != null) {
      firebaseStorageImageUrl = await FireBaseStorageController().uploadFilesToFireBaseStorage(data: thumbnailImage!, eventId: courseId, fileName: finalFileName);
      MyPrint.printOnConsole("Method after await");
    }
    return firebaseStorageImageUrl;
  }

  Future<void> addCaseOfMonthToFirebase() async {
    setState(() {
      isLoading = true;
    });

    String courseId = pageCourseModel?.id ?? "";
    if (courseId.isEmpty) {
      courseId = MyUtils.getNewId(isFromUUuid: false);
    }

    if (thumbnailImageName != null) {
      thumbnailImageUrl = await uploadFileToFirebaseStorage(courseId: courseId, imageName: thumbnailImageName!);
    }



    CaseOfMonthModel caseOfMonthModel = CaseOfMonthModel(
      id: courseId.trim(),
      caseName: eventCaseNameController.text.trim(),
      description: eventDescriptionController.text.trim(),
      image: thumbnailImageUrl?.trim() ?? "",
      createdTime: pageCourseModel?.createdTime ?? Timestamp.now(),
      updatedTime: pageCourseModel != null ? Timestamp.now() : null,
    );

    await caseOfMonthController.addCaseOfMonthToFirebase(
      caseOfMonth: caseOfMonthModel,
      isAdInProvider: pageCourseModel == null,
    );
    MyPrint.printOnConsole('Added Course Model is ${caseOfMonthModel.toMap()}');

    if (pageCourseModel != null) {
      CaseOfMonthModel model = pageCourseModel!;
      model.caseName = caseOfMonthModel.caseName;
      model.description = caseOfMonthModel.description;
      model.image = caseOfMonthModel.image;
      model.createdTime = caseOfMonthModel.createdTime;
      model.updatedTime = caseOfMonthModel.updatedTime;
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageCourseModel == null ? 'Case Of Month Added Successfully' : 'Case Of Month Edited Successfully');
    }
  }

  @override
  void initState() {
    super.initState();
    caseOfMonthProvider = Provider.of<CaseOfMonthProvider>(context, listen: false);
    caseOfMonthController = CaseOfMonthController(caseOfMonthProvider: caseOfMonthProvider);
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
                    HeaderWidget(title: pageCourseModel == null ? "Add Case Of Month" : "Edit Case Of Month", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getCaseName(),
                            const SizedBox(height: 20),
                            getDownloadUrlField(),
                            const SizedBox(height: 20),
                            getDescriptionTextField(),
                            const SizedBox(height: 20),
                            chooseThumbnailImageAndBackgroundColor(),
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

  Widget getCaseName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Case Name*"),
              CommonTextFormField(
                controller: eventCaseNameController,
                hintText: "Enter Case Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Case Name";
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getDownloadUrlField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        const SizedBox(width: 20),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getDescriptionTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Enter description of event"),
        CommonTextFormField(
          controller: eventDescriptionController,
          hintText: "Enter description of event",
          minLines: 3,
          maxLines: 10,
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }

  Widget chooseThumbnailImageAndBackgroundColor() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Choose Case Of Month Thumbnail Image"),
        thumbnailImage == null && thumbnailImageUrl == null && (thumbnailImageUrl?.isEmpty ?? true)
            ? InkWell(
                onTap: () async {
                  await addThumbnailImage();
                },
                child: const EmptyImageViewBox(),
              )
            : CommonImageViewBox(
                imageAsBytes: thumbnailImage,
                url: thumbnailImageUrl,
                rightOnTap: () {
                  thumbnailImage = null;
                  thumbnailImageUrl = null;
                  setState(() {});
                },
              ),
      ],
    );
  }

  Widget submitButton() {
    return CommonButton(
      onTap: () async {
        if (_formKey.currentState!.validate()) {
          // if (thumbnailImage == null && thumbnailImageUrl.checkEmpty) {
          //   MyToast.showError(context: context, msg: 'Please upload a course thumbnail image');
          //   return;
          // }

          dynamic newValue = await showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Are you sure want to ${pageCourseModel == null ? "Add" : "Edit"} this chapter?",
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

          await addCaseOfMonthToFirebase();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageCourseModel == null ? '+   Add Case Of Month ' : '+   Edit Case Of Month',
      fontSize: 17,
    );
  }
}
