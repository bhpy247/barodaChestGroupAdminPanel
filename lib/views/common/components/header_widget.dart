import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/common/menu_provider.dart';
import '../../../utils/app_colors.dart';
import 'app_response.dart';


class HeaderWidget extends StatefulWidget {
  String title;
  Widget? suffixWidget;
  bool isBackArrow = false;
  HeaderWidget({required this.title,this.suffixWidget,this.isBackArrow = false});
  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      child: Row(
        children: [
          if (!AppResponsive.isDesktop(context))
            IconButton(
              icon: Icon(
                Icons.menu,
                color: AppColor.black,
              ),
              onPressed: Provider.of<MenuProvider>(context, listen: false).controlMenu,
            ),
          if(widget.isBackArrow)
             Padding(
               padding: EdgeInsets.only(right: 10.0),
               child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.arrow_back_ios_rounded, size: 28,
                    color: AppColor.bgSideMenu,)),
             ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                widget.suffixWidget != null ? widget.suffixWidget! : Container()



              ],
            ),
          ),
          // if (!AppResponsive.isMobile(context)) ...{
          //   Spacer(),
          //   Row(
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       navigationIcon(icon: Icons.search),
          //       navigationIcon(icon: Icons.send),
          //       navigationIcon(icon: Icons.notifications_none_rounded),
          //     ],
          //   )
          // }
        ],
      ),
    );
  }

  Widget navigationIcon({icon}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        icon,
        color: AppColor.black,
      ),
    );
  }
}
