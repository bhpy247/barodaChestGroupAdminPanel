import 'package:baroda_chest_group_admin/views/common/components/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../utils/app_colors.dart';
import '../../common/components/common_text.dart';
import '../../common/components/dialog_header.dart';

class CustomColorPicker extends StatefulWidget {
  final Color? pickedColor;

  const CustomColorPicker({
    Key? key,
    this.pickedColor,
  }) : super(key: key);

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  Color? pickedColor;

  @override
  void initState() {
    super.initState();
    pickedColor = widget.pickedColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      content: Container(
        padding: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width * .5,
        // height: MediaQuery.of(context).size.height*.5,
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogHeader(title: "Pick Color"),
            const SizedBox(height: 20),
            ColorPicker(
              pickerColor: pickedColor ?? Colors.red,
              displayThumbColor: false,
              onColorChanged: (Color color) {
                pickedColor = color;
                setState(() {});
              },
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                CommonText(text: 'PickedColor : '),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: pickedColor,
                  ),
                  height: 50,
                  width: 150,
                )
              ],
            ),
            const SizedBox(height: 30),
            CommonButton(
              onTap: () {
                Navigator.pop(context, pickedColor);
              },
              text: 'Done',
            )
          ],
        ),
      ),
    );
  }
}
