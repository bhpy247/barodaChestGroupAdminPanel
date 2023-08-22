import 'dart:typed_data';

import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../backend/brochure/brochure_controller.dart';
import '../../../backend/brochure/brochure_provider.dart';
import '../../../backend/common/firebase_storage_controller.dart';
import '../../../backend/navigation/navigation_arguments.dart';
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

class AddBrochure extends StatefulWidget {
  static const String routeName = "/addcaseofmonth";
  final AddBrochureNavigationArguments arguments;

  const AddBrochure({super.key, required this.arguments});

  @override
  State<AddBrochure> createState() => _AddBrochureState();
}

class _AddBrochureState extends State<AddBrochure> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isCourseEnabled = true;

  late Future<void> futureGetData;
  late BrochureProvider brochureProvider;
  late BrochureController brochureController;
  DateTime? eventStartDate, eventEndDate;

  TextEditingController eventBrochureNameController = TextEditingController();
  TextEditingController googleDriveUrlController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();

  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  String? thumbnailImageName;

  BrochureModel? pageCourseModel;

  Future<void> getData() async {
    if (widget.arguments.brochureModel != null) {
      pageCourseModel = widget.arguments.brochureModel;
    }

    if (pageCourseModel != null) {
      eventBrochureNameController.text = pageCourseModel!.brochureName;
      googleDriveUrlController.text = pageCourseModel!.brochureUrl;
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

  Future<void> addBrochureToFirebase() async {
    setState(() {
      isLoading = true;
    });

    String courseId = pageCourseModel?.id ?? "";
    if (courseId.isEmpty) {
      courseId = MyUtils.getNewId(isFromUUuid: false);
    }

    BrochureModel brochureModel = BrochureModel(
      id: courseId.trim(),
      brochureName: eventBrochureNameController.text.trim(),
      brochureUrl: googleDriveUrlController.text.trim(),
      createdTime: pageCourseModel?.createdTime ?? Timestamp.now(),
      updatedTime: pageCourseModel != null ? Timestamp.now() : null,
    );

    await brochureController.addBrochureToFirebase(
      caseOfMonth: brochureModel,
      isAdInProvider: pageCourseModel == null,
    );
    MyPrint.printOnConsole('Added Course Model is ${brochureModel.toMap()}');

    if (pageCourseModel != null) {
      BrochureModel model = pageCourseModel!;
      model.brochureName = brochureModel.brochureName;
      model.brochureUrl = brochureModel.brochureUrl;
      model.createdTime = brochureModel.createdTime;
      model.updatedTime = brochureModel.updatedTime;
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageCourseModel == null ? 'Brochure Added Successfully' : 'Brochure Edited Successfully');
    }
  }

  @override
  void initState() {
    super.initState();
    brochureProvider = Provider.of<BrochureProvider>(context, listen: false);
    brochureController = BrochureController(brochureProvider: brochureProvider);
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
                    HeaderWidget(title: pageCourseModel == null ? "Add Brochure" : "Edit Brochure", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getCaseName(),
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

  Widget getCaseName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Brochure Name*"),
              CommonTextFormField(
                controller: eventBrochureNameController,
                hintText: "Enter Brochure Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Brochure Name";
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

          dynamic newValue = await showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Are you sure want to ${pageCourseModel == null ? "Add" : "Edit"} this brochure?",
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

          await addBrochureToFirebase();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageCourseModel == null ? '+   Add Brochure ' : '+   Edit Brochure',
      fontSize: 17,
    );
  }
}
