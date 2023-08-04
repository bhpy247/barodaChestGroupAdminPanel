import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class CommonProgressIndicator extends StatelessWidget {
  final Color? bgColor;
  final Color? progressColor;

  const CommonProgressIndicator({
    Key? key,
    this.bgColor,
    this.progressColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor ?? AppColor.bgColor,
      ),
      child: Center(child: CircularProgressIndicator(color: progressColor ?? AppColor.bgSideMenu)),
    );
  }
}
