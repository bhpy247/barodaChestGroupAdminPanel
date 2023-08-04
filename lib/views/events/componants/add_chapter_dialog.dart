import 'dart:typed_data';

import 'package:baroda_chest_group_admin/models/course/data_model/chapter_model.dart';
import 'package:baroda_chest_group_admin/utils/my_toast.dart';
import 'package:baroda_chest_group_admin/utils/my_utils.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_button.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/app_colors.dart';
import '../../common/components/common_image_view_box.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/dialog_header.dart';
import '../../common/components/get_title.dart';

class AddChapterDialog extends StatefulWidget {
  const AddChapterDialog({Key? key}) : super(key: key);

  @override
  State<AddChapterDialog> createState() => _AddChapterDialogState();
}

class _AddChapterDialogState extends State<AddChapterDialog> {
  ChapterModel chapterModel = ChapterModel();
  TextEditingController chapterNameController = TextEditingController();
  TextEditingController chapterDescriptionController = TextEditingController();
  TextEditingController chapterPreviewUrlController = TextEditingController();
  TextEditingController chapterGoogleformUrlController = TextEditingController();
  String chapterId = MyUtils.getNewId(isFromUUuid: false);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? thumbnailImageUrl;
  Uint8List? thumbnailImage;
  String? thumbnailImageName;

  void submit() {
    chapterModel.title = chapterNameController.text.trim();
    chapterModel.description = chapterDescriptionController.text.trim();
    chapterModel.url = chapterPreviewUrlController.text.trim();
    chapterModel.id = chapterId.trim();
    chapterModel.googleFormUrl = chapterGoogleformUrlController.text.trim();
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

  String? getThumbnailFromYoutubeUrl(String youtubeUrl) {
    String? finalUrl;
    String? midUrl = convertUrlToId(youtubeUrl);
    if (midUrl != null) {
      finalUrl = getThumbnail(videoId: midUrl);
    }
    return finalUrl;
  }

  String getThumbnail({
    required String videoId,
    String quality = ThumbnailQuality.standard,
    bool webp = true,
  }) =>
      webp ? 'https://i3.ytimg.com/vi_webp/$videoId/$quality.webp' : 'https://i3.ytimg.com/vi/$videoId/$quality.jpg';

  String? convertUrlToId(String url, {bool trimWhitespaces = true}) {
    if (!url.contains("http") && (url.length == 11)) return url;
    if (trimWhitespaces) url = url.trim();

    for (var exp in [
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/(?:music\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube\.com\/shorts\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$"),
      RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
    ]) {
      Match? match = exp.firstMatch(url);
      if (match != null && match.groupCount >= 1) return match.group(1);
    }

    return null;
  }

  Uint8List? value;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width * .5,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DialogHeader(title: "Fill necessary details of chapter"),
              const SizedBox(
                height: 20,
              ),
              CommonTextFormField(
                controller: chapterNameController,
                hintText: "Enter Chapter Name",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Chapter Name";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              CommonTextFormField(
                controller: chapterDescriptionController,
                hintText: "Enter Chapter Description",
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "  Please enter Description";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              CommonTextFormField(
                controller: chapterPreviewUrlController,
                hintText: "Enter Chapter url",
                onChanged: (val) async {
                  thumbnailImageUrl = getThumbnailFromYoutubeUrl(chapterPreviewUrlController.text.trim());
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 15,
              ),
              CommonTextFormField(
                controller: chapterGoogleformUrlController,
                hintText: "Enter Google Form url",
              ),
              const SizedBox(
                height: 15,
              ),
              GetTitle(title: 'Thumbnail for Chapter'),
              const SizedBox(
                height: 5,
              ),
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
              const SizedBox(
                height: 30,
              ),
              CommonButton(
                onTap: () {
                  bool isFormValidate = _formKey.currentState?.validate() ?? false;
                  bool isUrlValidate = chapterPreviewUrlController.text.trim().isNotEmpty || chapterGoogleformUrlController.text.trim().isNotEmpty;

                  if (isFormValidate && isUrlValidate) {
                    submit();
                    Navigator.pop(context, chapterModel);
                  } else if (!isUrlValidate) {
                    MyToast.showError(context: context, msg: "Add Chapter Url or Google Form Url");
                  }
                },
                text: 'Add Chapter',
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Quality of YouTube video thumbnail.
class ThumbnailQuality {
  /// 120*90
  static const String defaultQuality = 'default';

  /// 320*180
  static const String medium = 'mqdefault';

  /// 480*360
  static const String high = 'hqdefault';

  /// 640*480
  static const String standard = 'sddefault';

  /// Unscaled thumbnail
  static const String max = 'maxresdefault';
}
