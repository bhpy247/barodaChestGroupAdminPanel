import 'package:baroda_chest_group_admin/models/course/data_model/course_model.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_text_formfield.dart';
import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import '../../common/components/common_button.dart';
import '../../common/components/dialog_header.dart';

class AssignCourseValiditySelectionDialog extends StatefulWidget {
  final CourseModel courseModel;

  const AssignCourseValiditySelectionDialog({
    Key? key,
    required this.courseModel,
  }) : super(key: key);

  @override
  State<AssignCourseValiditySelectionDialog> createState() => _AssignCourseValiditySelectionDialogState();
}

class _AssignCourseValiditySelectionDialogState extends State<AssignCourseValiditySelectionDialog> with MySafeState {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController daysController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width * .5,
        constraints: BoxConstraints(
          maxHeight: context.sizeData.height * 0.8,
        ),
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
              DialogHeader(title: "Enter Enrollment Validity", fontSize: 20),
              getDaysSelectionTextField(),
              const SizedBox(height: 10),
              getSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getDaysSelectionTextField() {
    return CommonTextFormField(
      controller: daysController,
      hintText: "Enter Days",
      keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
      validator: (String? text) {
        if (text == null) {
          return "Days cannot be empty";
        }

        int? value = int.tryParse(text);
        if (value == null) {
          return "Days Invalid";
        }

        return null;
      },
    );
  }

  Widget getSubmitButton() {
    return CommonButton(
      onTap: () {
        if(_formKey.currentState?.validate() ?? false) {
          int? value = int.tryParse(daysController.text.trim());
          Navigator.pop(context, value);
        }
      },
      text: 'Submit',
    );
  }
}
