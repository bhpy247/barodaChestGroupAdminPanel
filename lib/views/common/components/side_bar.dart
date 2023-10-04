import 'package:flutter/material.dart';

import '../../../utils/app_colors.dart';
import 'common_text.dart';

class SideBar extends StatefulWidget {
  final List<Widget> drawerListTile;

  const SideBar({
    super.key,
    required this.drawerListTile,
  });

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: Container(
        color: AppColor.bgSideMenu,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    text: "Baroda Chest Group",
                    color: AppColor.yellow,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                  /* InkWell(
                      onTap: (){
                        // showDialog(context: context, builder: (context){
                        //   return NotificationDialog();
                        // });
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5,vertical: 5),
                          child: Icon(Icons.notifications,color: Colors.white,))),*/
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.drawerListTile,
                ),
              ),
            ),
            // Image.asset("assets/sidebar_image.png")
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback press;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.icon,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: Icon(
        icon,
        color: AppColor.white,
        size: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: AppColor.white),
      ),
    );
  }
}
