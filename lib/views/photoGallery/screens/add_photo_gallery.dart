import 'dart:io';
import 'dart:typed_data';

import 'package:baroda_chest_group_admin/backend/photo_gallery/photo_gallery_controller.dart';
import 'package:baroda_chest_group_admin/backend/photo_gallery/photo_gallery_provider.dart';
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
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

class AddPhotoGalleryScreen extends StatefulWidget {
  static const String routeName = "/addphotogallery";
  final AddPhotoGalleryNavigationArguments arguments;

  const AddPhotoGalleryScreen({super.key, required this.arguments});

  @override
  State<AddPhotoGalleryScreen> createState() => _AddPhotoGalleryScreenState();
}

class _AddPhotoGalleryScreenState extends State<AddPhotoGalleryScreen> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool isCourseEnabled = true;

  late Future<void> futureGetData;
  late PhotoGalleryProvider photoGalleryProvider;
  late PhotoGalleryController photoGalleryController;
  DateTime? eventStartDate, eventEndDate;

  TextEditingController albumNameController = TextEditingController();
  TextEditingController eventDescriptionController = TextEditingController();
  TextEditingController startDateTimeController = TextEditingController();

  List<String> thumbnailImageUrl = [];
  List<Uint8List> thumbnailImage = [];
  List<String>? thumbnailImageName;

  GalleryModel? pageGalleryModel;

  Future<void> getData() async {
    if (widget.arguments.galleryModel != null) {
      pageGalleryModel = widget.arguments.galleryModel;
    }

    if (pageGalleryModel != null) {
      albumNameController.text = pageGalleryModel!.eventName;
      eventDescriptionController.text = pageGalleryModel!.description;
      thumbnailImageUrl = pageGalleryModel!.imageList;
      eventStartDate = pageGalleryModel!.eventDate!.toDate();
      startDateTimeController.text = DatePresentation.ddMMMMyyyyHHMMTimeStamp(pageGalleryModel!.eventDate!);
    }
  }

  Future<void> addThumbnailImage() async {
    setState(() {});
    final picker = ImagePicker();
    final pickedFile = await picker.pickMultiImage(
        // source: ImageSource.gallery,
        );
    MyPrint.printOnConsole("pickedFile : ${pickedFile.length}");

    List<String> path = pickedFile.map((e) => e.path).toList();
    MyPrint.printOnConsole("path : ${path.length}");

    if (path.isNotEmpty) {
      for (XFile element in pickedFile) {
        File file = File(element.path);
        Uint8List data = await element.readAsBytes();
        thumbnailImage.add(data);
      }
    }
    thumbnailImageName = pickedFile.map((e) => e.name).toList();
    MyPrint.printOnConsole("thumbnailImage : ${thumbnailImage.length}");
    MyPrint.printOnConsole("thumbnailImageName : ${thumbnailImageName?.length}");
    if (mounted) setState(() {});
  }

  Future<String?> uploadFileToFirebaseStorage({required String courseId, required String imageName, required Uint8List? image}) async {
    String? firebaseStorageImageUrl;
    String finalFileName = MyUtils().getStorageUploadImageUrl(nativeImageName: imageName);
    if (image != null) {
      firebaseStorageImageUrl = await FireBaseStorageController().uploadFilesToFireBaseStorage(data: image, eventId: courseId, fileName: finalFileName, folderName: "photoGallery/");
      MyPrint.printOnConsole("Method after await");
    }
    return firebaseStorageImageUrl;
  }

  Future<void> addCaseOfMonthToFirebase() async {
    setState(() {
      isLoading = true;
    });

    String courseId = pageGalleryModel?.id ?? "";
    if (courseId.isEmpty) {
      courseId = MyUtils.getNewId(isFromUUuid: false);
    }
    MyPrint.printOnConsole("thumbnailImage : ${thumbnailImage.length}");
    MyPrint.printOnConsole("thumbnailImageName : ${thumbnailImageName?.length}");
    if (thumbnailImageName != null && thumbnailImage.isNotEmpty) {
      for (int i = 0; i < thumbnailImage.length; i++) {
        String url = await uploadFileToFirebaseStorage(courseId: courseId, imageName: thumbnailImageName![i], image: thumbnailImage[i]) ?? "";
        if (url.isNotEmpty) {
          thumbnailImageUrl.add(url);
        }
      }
    }

    if (thumbnailImageUrl.isEmpty) {
      // ignore: use_build_context_synchronously
      MyToast.showError(context: context, msg: 'There is some issue in uploading course image. Kindly try again!');
      return;
    }

    GalleryModel galleryModel = GalleryModel(
      id: courseId.trim(),
      eventName: albumNameController.text.trim(),
      description: eventDescriptionController.text.trim(),
      imageList: thumbnailImageUrl,
      // image: thumbnailImageUrl!.trim(),
      createdTime: pageGalleryModel?.createdTime ?? Timestamp.now(),
      eventDate:  Timestamp.fromDate(eventStartDate ?? DateTime.now()),
    );

    await photoGalleryController.addBrochureToFirebase(
      caseOfMonth: galleryModel,
      isAdInProvider: pageGalleryModel == null,
    );
    MyPrint.printOnConsole('Added Course Model is ${galleryModel.toMap()}');

    if (pageGalleryModel != null) {
      GalleryModel model = pageGalleryModel!;
      model.eventName = galleryModel.eventName;
      model.description = galleryModel.description;
      // model.image = galleryModel.image;
      model.imageList = galleryModel.imageList;
      model.createdTime = galleryModel.createdTime;
      model.eventDate = galleryModel.eventDate;
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageGalleryModel == null ? 'Photo Gallery Added Successfully' : 'Photo Gallery Edited Successfully');
    }
  }

  Future<void> startDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025).add(const Duration(days: 365)),
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

  @override
  void initState() {
    super.initState();
    photoGalleryProvider = Provider.of<PhotoGalleryProvider>(context, listen: false);
    photoGalleryController = PhotoGalleryController(photoGalleryProvider: photoGalleryProvider);
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    MyPrint.printOnConsole("pageCourseModel?.id:${pageGalleryModel?.id}");

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
                    HeaderWidget(title: pageGalleryModel == null ? "Add Photo Gallery" : "Edit Photo Gallery", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getEventName(),
                            const SizedBox(height: 20),
                            getStartDateTextField(),
                            const SizedBox(height: 20),
                            getImageListViewWidget(),
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

  Widget getEventName() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GetTitle(title: "Enter album name*"),
              CommonTextFormField(
                controller: albumNameController,
                hintText: "Enter album name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter album name";
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

  Widget getImageListViewWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GetTitle(title: "Choose multiple photos for this album"),
        thumbnailImage.isEmpty && thumbnailImageUrl.isEmpty && (thumbnailImageUrl.isEmpty ?? true)
            ? InkWell(
                onTap: () async {
                  await addThumbnailImage();
                },
                child: const EmptyImageViewBox(),
              )
            : getImageList()
      ],
    );
  }

  Widget getImageList() {
    MyPrint.printOnConsole("thumbnailImageUrl.length: ${thumbnailImageUrl.length}");
    // if(thumbnailImage.isEmpty ) return const SizedBox();
    return SizedBox(
      height: 80,
      width: double.infinity,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: thumbnailImage.isNotEmpty
            ? List.generate(thumbnailImage.length, (index) {
                return CommonImageViewBox(
                  imageAsBytes: thumbnailImage[index],
                  rightOnTap: () {
                    if (thumbnailImage.isNotEmpty) {
                      thumbnailImage.removeAt(index);
                    }
                    setState(() {});
                  },
                );
              })
            : List.generate(thumbnailImageUrl.length, (index) {
                return CommonImageViewBox(
                  url: thumbnailImageUrl[index],
                  rightOnTap: () {
                    if (thumbnailImageUrl.isNotEmpty) {
                      thumbnailImageUrl.removeAt(index);
                    }
                    setState(() {});
                  },
                );
              }),
      ),
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
                text: "Are you sure want to ${pageGalleryModel == null ? "Add" : "Edit"} this data?",
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
      text: pageGalleryModel == null ? '+   Add Photo Gallery ' : '+   Edit Photo Gallery',
      fontSize: 17,
    );
  }
}
