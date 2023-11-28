import 'package:baroda_chest_group_admin/backend/admin/admin_controller.dart';
import 'package:baroda_chest_group_admin/backend/admin/admin_provider.dart';
import 'package:baroda_chest_group_admin/models/admin/property_model.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_button.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_text.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_text_formfield.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/components/header_widget.dart';

class AssetsUploadScreen extends StatefulWidget {
  const AssetsUploadScreen({super.key});

  @override
  State<AssetsUploadScreen> createState() => _AssetsUploadScreenState();
}

class _AssetsUploadScreenState extends State<AssetsUploadScreen> with MySafeState {
  TextEditingController homeScreenBanner = TextEditingController();
  TextEditingController cmeBanner = TextEditingController();
  TextEditingController photoGalleryController = TextEditingController();
  TextEditingController comController = TextEditingController();
  TextEditingController pastEventController = TextEditingController();
  TextEditingController upcomingEventController = TextEditingController();
  TextEditingController contactUsController = TextEditingController();
  TextEditingController membershipController = TextEditingController();
  TextEditingController guideLineController = TextEditingController();
  TextEditingController aimsAndObjectiveController = TextEditingController();

  final key = GlobalKey<FormState>();
  late AdminController adminController;
  late AdminProvider adminProvider;
  AssetsUploadModel assetsUploadModel = AssetsUploadModel();

  void getData() {
    assetsUploadModel = adminProvider.assetsUploadedModel.get() ?? AssetsUploadModel();
    homeScreenBanner.text = assetsUploadModel.webHomeBannerAsset;
    cmeBanner.text = assetsUploadModel.cmeBrochure;
    photoGalleryController.text = assetsUploadModel.photoGallery;
    pastEventController.text = assetsUploadModel.pastEvent;
    upcomingEventController.text = assetsUploadModel.upcomingEvent;
    contactUsController.text = assetsUploadModel.contactUs;
    guideLineController.text = assetsUploadModel.guideLine;
    comController.text = assetsUploadModel.caseOfMonth;
    membershipController.text = assetsUploadModel.membershipBanner;
    aimsAndObjectiveController.text = assetsUploadModel.aimsAndObjectiveImage;
    mySetState();
  }

  @override
  void initState() {
    super.initState();
    adminProvider = context.read<AdminProvider>();
    adminController = AdminController(adminProvider: adminProvider);
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainWidget(),
    );
  }

  Widget mainWidget() {
    return Consumer<AdminProvider>(builder: (context, AdminProvider provider, _) {
      AssetsUploadModel assetsUploadModel = provider.assetsUploadedModel.get() ?? AssetsUploadModel();
      return Form(
        key: key,
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeaderWidget(
                title: "Assets Upload",
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Home Page Banner",
                          url: assetsUploadModel.webHomeBannerAsset,
                          controller: homeScreenBanner,
                          onTap: () {
                            assetsUploadModel.webHomeBannerAsset = homeScreenBanner.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Cme Brochure Banner",
                          url: assetsUploadModel.cmeBrochure,
                          controller: cmeBanner,
                          onTap: () {
                            assetsUploadModel.cmeBrochure = cmeBanner.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Photo Gallery Banner",
                          url: assetsUploadModel.photoGallery,
                          controller: photoGalleryController,
                          onTap: () {
                            assetsUploadModel.photoGallery = photoGalleryController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Upcoming Activities Banner",
                          url: assetsUploadModel.upcomingEvent,
                          controller: upcomingEventController,
                          onTap: () {
                            assetsUploadModel.upcomingEvent = upcomingEventController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Past Activity Banner",
                          url: assetsUploadModel.pastEvent,
                          controller: pastEventController,
                          onTap: () {
                            assetsUploadModel.pastEvent = pastEventController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Case Of Month Banner",
                          url: assetsUploadModel.caseOfMonth,
                          controller: comController,
                          onTap: () {
                            assetsUploadModel.caseOfMonth = comController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Contact Us Banner",
                          url: assetsUploadModel.contactUs,
                          controller: contactUsController,
                          onTap: () {
                            assetsUploadModel.contactUs = contactUsController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "GuideLine Banner",
                          url: assetsUploadModel.guideLine,
                          controller: guideLineController,
                          onTap: () {
                            assetsUploadModel.guideLine = guideLineController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Membership Banner",
                          url: assetsUploadModel.membershipBanner,
                          controller: membershipController,
                          onTap: () {
                            assetsUploadModel.membershipBanner = membershipController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Flexible(
                        child: getImageWidgetWithButton(
                          text: "Aims And Object Image",
                          url: assetsUploadModel.aimsAndObjectiveImage,
                          controller: aimsAndObjectiveController,
                          onTap: () {
                            assetsUploadModel.aimsAndObjectiveImage = aimsAndObjectiveController.text.trim();

                            adminController.updateAssetModelDataAndSetInProvider(assetsUploadModel);
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return "Please Enter Url";
                            } else if (!(val.contains("http") || val.contains("https"))) {
                              return "Please enter valid URL";
                            }
                            return "";
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget getImageWidgetWithButton({required String text, required String url, Function()? onTap, required TextEditingController controller, String Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CommonText(
            text: text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          SizedBox(
            height: 10,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              height: 150,
              width: double.infinity,
              errorWidget: (_, __, ___) {
                return Container(
                  child: Icon(
                    Icons.image,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 10,
          ),
          CommonTextFormField(
            controller: controller,
            hintText: text,
            validator: validator,
          ),
          SizedBox(
            height: 10,
          ),
          CommonButton(onTap: onTap, text: "Save")
        ],
      ),
    );
  }
}
