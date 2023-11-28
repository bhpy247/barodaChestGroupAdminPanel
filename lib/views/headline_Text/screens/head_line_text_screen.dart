import 'package:baroda_chest_group_admin/backend/admin/admin_controller.dart';
import 'package:baroda_chest_group_admin/utils/extensions.dart';
import 'package:baroda_chest_group_admin/utils/my_safe_state.dart';
import 'package:baroda_chest_group_admin/views/common/components/common_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/admin/admin_provider.dart';
import '../../../models/admin/property_model.dart';
import '../../../utils/app_colors.dart';
import '../../common/components/common_button.dart';
import '../../common/components/common_text_formfield.dart';
import '../../common/components/header_widget.dart';

class HeadLineTextScreen extends StatefulWidget {
  const HeadLineTextScreen({super.key});

  @override
  State<HeadLineTextScreen> createState() => _HeadLineTextScreenState();
}

class _HeadLineTextScreenState extends State<HeadLineTextScreen> with MySafeState {
  TextEditingController controller = TextEditingController();
  String text = "";

  @override
  Widget build(BuildContext context) {
    super.pageBuild();
    return Consumer<AdminProvider>(builder: (context, AdminProvider provider, _) {
      PropertyModel pm = provider.propertyModel.get() ?? PropertyModel();
      // if(pm.headLineText.checkEmpty) return SizedBox();
      return Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderWidget(
              title: "Headline Text",
            ),
            const SizedBox(height: 10),
            CommonText(text: "Headline Text : ${pm.headLineText}"),
            const SizedBox(height: 10),
            CommonTextFormField(
              controller: controller,
              hintText: "Add Headline Text",
              onChanged: (String? val) {
                text = val ?? "";
                mySetState();
              },
            ),
            const SizedBox(height: 10),
            CommonButton(
              onTap: text.checkEmpty
                  ? null
                  : () async {
                      pm.headLineText = text.trim();
                      await AdminController(adminProvider: provider).updatePropertyDataOnlineAndSetInProvider(pm);
                      controller.clear();
                      mySetState();
                    },
              text: "Save",
              backgroundColor: text.isEmpty ? AppColor.bgSideMenu.withOpacity(.5) : AppColor.bgSideMenu,
            )
          ],
        ),
      );
    });
  }
}
