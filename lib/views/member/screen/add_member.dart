
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/member/member_controller.dart';
import '../../../backend/member/member_provider.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../models/profile/data_model/member_model.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../../utils/my_utils.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_popup.dart';
import '../../common/components/common_progress_indicator.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/get_title.dart';
import '../../common/components/header_widget.dart';
import '../../common/components/modal_progress_hud.dart';

class AddMemberScreen extends StatefulWidget {
  static const String routeName = "/addmember";
  final AddMemberScreenNavigationArguments arguments;

  const AddMemberScreen({super.key, required this.arguments});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  late Future<void> futureGetData;
  late MemberProvider memberProvider;
  late MemberController memberController;

  TextEditingController nameController = TextEditingController();
  TextEditingController designationController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();


  MemberModel? pageMemberModel;

  Future<void> getData() async {
    if (widget.arguments.memberModel != null) {
      pageMemberModel = widget.arguments.memberModel;
    }

    if (pageMemberModel != null) {
      nameController.text = pageMemberModel!.name;
      designationController.text = pageMemberModel!.designation;
      emailController.text = pageMemberModel!.email;
      addressController.text = pageMemberModel!.address;
    }
  }

  Future<void> addMemberToFirebase() async {
    setState(() {
      isLoading = true;
    });

    String courseId = pageMemberModel?.id ?? "";
    if (courseId.isEmpty) {
      courseId = MyUtils.getNewId(isFromUUuid: false);
    }

    MemberModel memberModel = MemberModel(
      id: courseId.trim(),
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      designation: designationController.text.trim(),
      address: addressController.text.trim(),
      createdTime: pageMemberModel?.createdTime ?? Timestamp.now(),
      // updatedTime: pageCourseModel != null ? Timestamp.now() : null,
    );

    await memberController.addMemberToFirebase(
      memberModel: memberModel,
      isAdInProvider: pageMemberModel == null,
    );
    MyPrint.printOnConsole('Added Member Model is ${memberModel.toMap()}');

    if (pageMemberModel != null) {
      MemberModel model = pageMemberModel!;
      model.name = memberModel.name;
      model.designation = memberModel.designation;
      model.address = memberModel.address;
      model.email = memberModel.email;
      model.createdTime = memberModel.createdTime;
    }

    setState(() {
      isLoading = false;
    });
    if (context.mounted && context.checkMounted()) {
      MyToast.showSuccess(context: context, msg: pageMemberModel == null ? 'Member Added Successfully' : 'Member Edited Successfully');
    }
  }

  @override
  void initState() {
    super.initState();
    memberProvider = Provider.of<MemberProvider>(context, listen: false);
    memberController = MemberController(memberProvider: memberProvider);
    futureGetData = getData();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    MyPrint.printOnConsole("pageCourseModel?.id:${pageMemberModel?.id}");

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
                    HeaderWidget(title: pageMemberModel == null ? "Add Member" : "Edit Member", isBackArrow: true),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            getName(),
                            const SizedBox(height: 20),
                            getEmailTextField(),
                            const SizedBox(height: 20),
                            getDesignationUrlField(),
                            const SizedBox(height: 20),
                            getAddrressTextField(),
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
        const SizedBox(width: 20),
        Expanded(child: Container()),
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
        const SizedBox(width: 20),
        Expanded(child: Container()),
      ],
    );
  }

  Widget getAddrressTextField() {
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
                text: "Are you sure want to ${pageMemberModel == null ? "Add" : "Edit"} this member?",
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

          await addMemberToFirebase();
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }
      },
      text: pageMemberModel == null ? '+   Add Member ' : '+   Edit Member',
      fontSize: 17,
    );
  }
}
