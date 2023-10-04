import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_controller.dart';
import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_controller.dart';
import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_provider.dart';
import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_provider.dart';
import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';
import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';
import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';
import 'package:baroda_chest_group_admin/models/academic_connect/data_model/academic_connect_model.dart';
import 'package:baroda_chest_group_admin/utils/date_presentation.dart';
import 'package:baroda_chest_group_admin/utils/parsing_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baroda_chest_group_admin/backend/navigation/navigation_arguments.dart';
import 'package:baroda_chest_group_admin/models/course/data_model/chapter_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/utils/my_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../backend/common/firebase_storage_controller.dart';
import '../../../backend/event_backend/event_controller.dart';
import '../../../backend/event_backend/event_provider.dart';
import '../../../models/event/data_model/event_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_image_view_box.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/get_title.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class AddAcademicConnect extends StatefulWidget {
  static const String routeName = "/AddAcademicConnect";
  final AddAcademicConnectScreenNavigationArguments arguments;

  const AddAcademicConnect({Key? key, required this.arguments}) : super(key: key);

  @override
  State<AddAcademicConnect> createState() => _AddAcademicConnectState();
}

class _AddAcademicConnectState extends State<AddAcademicConnect> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isCourseEnabled = true;

  late Future<void> futureGetData;
  late AcademicConnectProvider academicConnectProvider;
  late AcademicConnectController academicConnectController;
  DateTime? eventStartDate, eventEndDate;

  TextEditingController eventNameController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController startDateTimeController = TextEditingController();
  TextEditingController endDateTimeController = TextEditingController();
  TextEditingController totalSeatController = TextEditingController();
  TextEditingController downloadUrlController = TextEditingController();

  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  String? thumbnailImageName;

  Color pickedColor = Colors.red;

  List<ChapterModel> chapters = [];

  AcademicConnectModel? pageCourseModel;

  Future<void> getData() async {
    if (widget.arguments.academicConnectModel != null) {
      pageCourseModel = widget.arguments.academicConnectModel;
    }

    if (pageCourseModel != null) {
      eventNameController.text = pageCourseModel!.title;
      eventDescriptionController.text = pageCourseModel!.description;
      thumbnailImageUrl = pageCourseModel!.imageUrl;
      eventStartDate = pageCourseModel!.eventStartDate!.toDate();
      eventEndDate = pageCourseModel!.eventEndDate!.toDate();
      addressController.text = pageCourseModel!.address;
      totalSeatController.text = pageCourseModel!.totalSeats.toString();
      eventEndDate = pageCourseModel!.eventEndDate!.toDate();
      downloadUrlController.text = pageCourseModel!.downloadUrl;
      startDateTimeController.text = DatePresentation.ddMMMMyyyyHHMMTimeStamp(pageCourseModel!.eventStartDate!);
      endDateTimeController.text = DatePresentation.ddMMMMyyyyHHMMTimeStamp(pageCourseModel!.eventEndDate!);
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
      // CroppedFile? croppedFile = await ImageCropper().cropImage(
      //   compressFormat: ImageCompressFormat.jpg,
      //   sourcePath: path,
      //   aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      //   cropStyle: CropStyle.rectangle,
      //   uiSettings: [
      //     AndroidUiSettings(
      //       toolbarTitle: 'Crop Image',
      //       toolbarColor: AppColor.bgSideMenu,
      //       toolbarWidgetColor: Colors.white,
      //       initAspectRatio: CropAspectRatioPreset.square,
      //       lockAspectRatio: true,
      //     ),
      //     IOSUiSettings(
      //       minimumAspectRatio: 1.0,
      //       aspectRatioLockEnabled: true,
      //       aspectRatioPickerButtonHidden: true,
      //     ),
      //     // ignore: use_build_context_synchronously
      //     WebUiSettings(
      //       context: context,
      //       presentStyle: CropperPresentStyle.dialog,
      //       boundary: const CroppieBoundary(
      //         width: 530,
      //         height: 330,
      //       ),
      //       viewPort: const CroppieViewPort(width: 400, height: 225, type: 'rectangular'),
      //       enableOrientation: true,
      //       enableExif: true,
      //       enableZoom: true,
      //       showZoomer: true,
      //     ),
      //   ],
      // );
      // if (croppedFile != null) {
        thumbnailImage = await pickedFile.readAsBytes();
      // }
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

  Future<void> addCourseToFirebase() async {
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

    if (thumbnailImageUrl == null) {
      // ignore: use_build_context_synchronously
      MyToast.showError(context: context, msg: 'There is some issue in uploading course image. Kindly try again!');
      return;
    }

    AcademicConnectModel eventModel = AcademicConnectModel(
      id: courseId.trim(),
      eventStartDate: Timestamp.fromDate(eventStartDate!),
      eventEndDate: Timestamp.fromDate(eventEndDate!),
      title: eventNameController.text.trim(),
      description: eventDescriptionController.text.trim(),
      address: addressController.text.trim(),
      downloadUrl: downloadUrlController.text.trim(),
      totalSeats: ParsingHelper.parseIntMethod(totalSeatController.text.trim()),
      imageUrl: thumbnailImageUrl!.trim(),
      createdTime: pageCourseModel?.createdTime ?? Timestamp.now(),
      updatedTime: pageCourseModel != null ? Timestamp.now() : null,
    );

    await academicConnectController. addAcademicConnectToFirebase(
      academicConnectModel: eventModel,
      isAdInProvider: pageCourseModel == null,
    );
    MyPrint.printOnConsole('Added Course Model is ${eventModel.toMap()}');

    if (pageCourseModel != null) {
      AcademicConnectModel model = pageCourseModel!;
      model.title = eventModel.title;
      model.description = eventModel.description;
      model.imageUrl = eventModel.imageUrl;
      model.totalSeats = eventModel.totalSeats;
      model.address = eventModel.address;
      model.createdTime = eventModel.createdTime;
      model.updatedTime = eventModel.updatedTime;
      model.eventStartDate = eventModel.eventStartDate;
      model.eventEndDate = eventModel.eventEndDate;
    }

    setState(() {
      isLoading = false;
    });
    if(context.mounted && context.checkMounted()){
      MyToast.showSuccess(context: context, msg: pageCourseModel == null ? 'Academic Connect Added Successfully' : 'Academic Connect Edited Successfully');
    }
  }

  Future<void> startDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025).add(Duration(days: 365)),
    );
    if (context.mounted && context.checkMounted()) {
      TimeOfDay? startTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
      // startTime.
      MyPrint.printOnConsole("start time: $startTime");

      if (pickedDate != null && startTime != null) {
        eventStartDate = pickedDate.copyWith(
          hour: startTime.hour,
          minute: startTime.minute,
        );
        if (eventStartDate != null) {
          startDateTimeController.text = DatePresentation.ddMMMMyyyyHHMMTimeStamp(
            Timestamp.fromDate(
              eventStartDate!,
            ),
          );
        }
      }
    }
    mySetState();
  }

  Future<void> endDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025).add(Duration(days: 365)),
    );
    if (context.mounted && context.checkMounted()) {
      TimeOfDay? endTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());

      MyPrint.printOnConsole("start time: $endTime");

      if (pickedDate != null && endTime != null) {
        eventEndDate = pickedDate.copyWith(hour: endTime.hour, minute: endTime.minute, second: 0, microsecond: 0, millisecond: 0);
        if(eventEndDate != null) {
          endDateTimeController.text = DatePresentation.ddMMMMyyyyHHMMTimeStamp(
            Timestamp.fromDate(eventEndDate!),
          );
        }
      }
    }
    mySetState();
  }

  @override
  void initState() {
    super.initState();
    academicConnectProvider = Provider.of<AcademicConnectProvider>(context, listen: false);
    academicConnectController = AcademicConnectController(academicConnectProvider: academicConnectProvider);
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
                    HeaderWidget(title: pageCourseModel == null ? "Add Academic Connect" : "Edit Academic Connect", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getAcademicConnectTitle(),
                            const SizedBox(height: 20),
                            getDescriptionTextField(),
                            const SizedBox(height: 20),
                            getAddressTextField(),
                            const SizedBox(height: 30),
                            getDownloadUrlTextField(),
                            const SizedBox(height: 30),
                            // getTotalSeatTextField(),
                            // const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: getStartDateTextField()),
                                Expanded(child: getEndDateTextField()),
                              ],
                            ),
                            const SizedBox(height: 30),
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

  Widget getAcademicConnectTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter Academic Connect Title*"),
              CommonTextFormField(
                controller: eventNameController,
                hintText: "Enter Academic Connect Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Academic Connect Name";
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

  Widget getDescriptionTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Enter description of academic connect"),
        CommonTextFormField(
          controller: eventDescriptionController,
          hintText: "Enter description of academic connect",
          minLines: 3,
          maxLines: 10,
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }

  Widget getStartDateTextField() {
    return InkWell(
      onTap: () {
        startDateTime();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetTitle(title: "Select start date & time"),
          CommonTextFormField(
            enabled: false,
            controller: startDateTimeController,
            hintText: "Select start date",
            minLines: 1,
            validator: (value) {
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget getEndDateTextField() {
    return InkWell(
      onTap: () {
        endDateTime();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetTitle(title: "Select end date & time"),
          CommonTextFormField(
            controller: endDateTimeController,
            hintText: "Select end date",
            minLines: 1,
            enabled: false,
            validator: (value) {
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget getAddressTextField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Address"),
              CommonTextFormField(
                controller: addressController,
                hintText: "Enter Address",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter address";
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
  Widget getDownloadUrlTextField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Download URL"),
              CommonTextFormField(
                controller: downloadUrlController,
                hintText: "Enter Download URL",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter download URL";
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

  Widget getTotalSeatTextField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Total Seat"),
              CommonTextFormField(
                controller: totalSeatController,
                hintText: "Enter total seat",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter total seat";
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

  Widget chooseThumbnailImageAndBackgroundColor() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Choose Academic Connect Thumbnail Image*"),
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
          if (thumbnailImage == null && thumbnailImageUrl.checkEmpty) {
            MyToast.showError(context: context, msg: 'Please upload a course thumbnail image');
            return;
          }

          dynamic newValue = await showDialog(
            context: context,
            builder: (context) {
              return CommonPopup(
                text: "Are you sure want to ${pageCourseModel == null ? "Add" : "Edit"} this academic connect?",
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

          await addCourseToFirebase();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageCourseModel == null ? '+   Add Academic Connect' : '+   Edit Academic Connect',
      fontSize: 17,
    );
  }
}
