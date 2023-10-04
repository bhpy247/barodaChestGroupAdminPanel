import 'dart:typed_data';

import 'package:baroda_chest_group_admin/backend/committee_member/committee_member_controller.dart';
import 'package:baroda_chest_group_admin/backend/committee_member/committee_member_provider.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../backend/common/firebase_storage_controller.dart';
import '../../../backend/member/member_controller.dart';
import '../../../backend/member/member_provider.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../models/profile/data_model/member_model.dart';
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

class AddCommitteeMemberScreen extends StatefulWidget {
  static const String routeName = "/addcommitteemember";
  final AddCommitteeMemberScreenNavigationArguments arguments;

  const AddCommitteeMemberScreen({super.key, required this.arguments});

  @override
  State<AddCommitteeMemberScreen> createState() => _AddCommitteeMemberScreenState();
}

class _AddCommitteeMemberScreenState extends State<AddCommitteeMemberScreen> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late Future<void> futureGetData;
  late CommitteeMemberProvider committeeMemberProvider;
  late CommitteeMemberController committeeMemberController;

  TextEditingController nameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? selectedType;

  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  String? thumbnailImageName;

  CommitteeMemberModel? pageCommitteeMemberModel;

  Future<void> getData() async {
    if (widget.arguments.committeeMemberModel != null) {
      pageCommitteeMemberModel = widget.arguments.committeeMemberModel;
    }

    if (pageCommitteeMemberModel != null) {
      nameController.text = pageCommitteeMemberModel!.name;
      addressController.text = pageCommitteeMemberModel!.type;
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

  Future<void> addCommitteeMemberToFirebase() async {
    setState(() {
      isLoading = true;
    });

    String courseId = pageCommitteeMemberModel?.id ?? "";
    if (courseId.isEmpty) {
      courseId = MyUtils.getNewId(isFromUUuid: false);
    }

    if (thumbnailImageName != null) {
      thumbnailImageUrl = await uploadFileToFirebaseStorage(courseId: courseId, imageName: thumbnailImageName!);
    }

    // if (thumbnailImageUrl == null) {
    //   // ignore: use_build_context_synchronously
    //   MyToast.showError(context: context, msg: 'There is some issue in uploading course image. Kindly try again!');
    //   return;
    // }

    CommitteeMemberModel memberModel = CommitteeMemberModel(
      id: courseId.trim(),
      name: nameController.text.trim(),
      type: selectedType ?? "",
      profileUrl: thumbnailImageUrl?.trim() ?? "",
      createdTime: pageCommitteeMemberModel?.createdTime ?? Timestamp.now(),
      // updatedTime: pageCourseModel != null ? Timestamp.now() : null,
    );

    await committeeMemberController.addCommitteeMemberToFirebase(
      committeeMemberModel: memberModel,
      isAdInProvider: pageCommitteeMemberModel == null,
    );
    MyPrint.printOnConsole('Added Member Model is ${memberModel.toMap()}');

    if (pageCommitteeMemberModel != null) {
      CommitteeMemberModel model = pageCommitteeMemberModel!;
      model.name = memberModel.name;
      model.type = memberModel.type;
      model.profileUrl = model.profileUrl;
      model.createdTime = memberModel.createdTime;
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageCommitteeMemberModel == null ? 'Member Added Successfully' : 'Member Edited Successfully');
    }
  }

  @override
  void initState() {
    super.initState();
    committeeMemberProvider = Provider.of<CommitteeMemberProvider>(context, listen: false);
    committeeMemberController = CommitteeMemberController(committeeMemberProvider: committeeMemberProvider);
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    MyPrint.printOnConsole("pageCourseModel?.id:${pageCommitteeMemberModel?.id}");

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
                    HeaderWidget(title: pageCommitteeMemberModel == null ? "Add Committee Member" : "Edit Committee Member", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getName(),
                            const SizedBox(height: 20),
                            getDropDownForType(),
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

  Widget getName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Name*"),
              CommonTextFormField(
                controller: nameController,
                hintText: "Enter Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Name";
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

  Widget getDesignationUrlField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter designation"),
              CommonTextFormField(
                controller: designationController,
                hintText: "Enter designation",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter designation";
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

  Widget getAddressTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Enter address "),
        CommonTextFormField(
          controller: addressController,
          hintText: "Enter address",
          minLines: 3,
          maxLines: 10,
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }

  Widget getEmailTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Enter email "),
        CommonTextFormField(
          controller: emailController,
          hintText: "Enter email",
          minLines: 3,
          maxLines: 10,
          validator: (value) {
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
                text: "Are you sure want to ${pageCommitteeMemberModel == null ? "Add" : "Edit"} this member?",
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

          await addCommitteeMemberToFirebase();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageCommitteeMemberModel == null ? '+   Add Member ' : '+   Edit Member',
      fontSize: 17,
    );
  }

  Widget getDropDownForType() {
    return Card(
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      elevation: 2,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          filled: true,
          hintText: 'Select type',
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 21),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(4),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(4),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.black.withOpacity(.75),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        items: <String>[
          'Patron',
          'President',
          'Vice President',
          'Secretary',
          'Treasurer',
          'Member Radiology',
          'Social Media & Website',
          "Charitable Activity",
          "Academics",
          "Member",
        ].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        value: selectedType,
        onChanged: (String? value) {
          if (value != null) {
            selectedType = value;
          }
        },
      ),
    );
  }

  Widget chooseThumbnailImageAndBackgroundColor() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Choose Profile Image"),
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
}
