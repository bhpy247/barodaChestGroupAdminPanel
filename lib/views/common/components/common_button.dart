import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';

class CommonButton extends StatelessWidget {
  Function()? onTap;
  String text;
  double verticalPadding;
  double horizontalPadding;
  Color backgroundColor;
  double fontSize;
  double borderRadius;
  Widget? icon;
  Widget? suffixIcon;
  bool isSelected = true;

  CommonButton({
    Key? key,
    required this.onTap,
    required this.text,
    this.verticalPadding=10,
    this.fontSize=15,
    this.icon,
    this.suffixIcon,
    this.borderRadius=4,
    this.horizontalPadding=20,
    this.backgroundColor=AppColor.bgSideMenu,
    this.isSelected=true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding,horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: isSelected?backgroundColor:AppColor.white,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(color: isSelected?Colors.transparent:AppColor.bgSideMenu,width: 1),

          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null ? Padding(
                padding:  EdgeInsets.only(right: 4.0),
                child: icon!,
              ) : Container(),
              Text(
                text,
                style: TextStyle(
                  color: isSelected?AppColor.white:AppColor.bgSideMenu.withOpacity(0.6),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              suffixIcon != null ? Padding(
                padding:  EdgeInsets.only(left: 4.0),
                child: suffixIcon!,
              ) : Container(),
            ],
          )),
    );
  }
}
