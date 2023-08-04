import 'package:baroda_chest_group_admin/views/caseofmonth/screens/case_of_month_list.dart';
import 'package:baroda_chest_group_admin/views/events/screens/event_list_screen.dart';
import 'package:baroda_chest_group_admin/views/users/screens/users_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../backend/common/menu_provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../../common/components/app_response.dart';
import '../../common/components/side_bar.dart';
import '../../feedback/screens/feedbacks_list_screen.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/HomePage';

  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int tabNumber = 0;

  @override
  void initState() {
    super.initState();
    MyPrint.printOnConsole('On Main Home Page');
  }

  @override
  Widget build(BuildContext context) {
    // if(NavigationController.isFirst) {
    //   MyPrint.printOnConsole("isFirst called");
    //   return const SizedBox();
    // }

    return Scaffold(
      drawer: SideBar(drawerListTile: [
        DrawerListTile(
          title: "Users",
          icon: Icons.account_box_outlined,
          press: () {
            setState(() {
              tabNumber=0;
            });
          },
        ),
        DrawerListTile(
          title: "Devices",
          icon: Icons.view_in_ar_outlined,
          press: () {
            setState(() {
              tabNumber=1;
            });
          },
        ),
        DrawerListTile(
          title: "Games",
          icon: Icons.videogame_asset_outlined,
          press: () {
            setState(() {
              tabNumber=2;
            });
          },
        ),
        DrawerListTile(
          title: "Orders",
          icon: Icons.auto_graph,
          press: () {
            setState(() {
              tabNumber=3;
            });
          },
        ),
        DrawerListTile(
          title: "Subscriptions",
          icon: Icons.dashboard,
          press: () {
            setState(() {
              tabNumber=4;
            });
          },
        ),
        DrawerListTile(
          title: "OKOTO",
          icon: Icons.library_books_outlined,
          press: () {
            setState(() {
              tabNumber=5;
            });
          },
        ),
      ]),
      key: Provider.of<MenuProvider>(context, listen: false).scaffoldKey,
      backgroundColor: AppColor.bgSideMenu,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (AppResponsive.isDesktop(context))
              Expanded(
                child: SideBar(
                  drawerListTile: [
                    DrawerListTile(
                      title: "Events",
                      icon: Icons.account_box_outlined,
                      press: () {
                        setState(() {
                          tabNumber=0;
                        });
                      },
                    ),
                    DrawerListTile(
                      title: "Case Of Month",
                      icon: Icons.view_in_ar_outlined,
                      press: () {
                        setState(() {
                          tabNumber=1;
                        });
                      },
                    ),
                    DrawerListTile(
                      title: "Brochure",
                      icon: MdiIcons.frequentlyAskedQuestions,
                      press: () {
                        setState(() {
                          tabNumber=2;
                        });
                      },
                    ),
                    DrawerListTile(
                      title: "Settings",
                      icon: Icons.feedback,
                      press: () {
                        setState(() {
                          tabNumber=3;
                        });
                      },
                    ),
                    // DrawerListTile(
                    //   title: "Subscriptions",
                    //   icon: Icons.dashboard,
                    //   press: () {
                    //     setState(() {
                    //       tabNumber=4;
                    //     });
                    //   },
                    // ),
                    /*DrawerListTile(
                      title: "System",
                      icon: Icons.library_books_outlined,
                      press: () {
                        setState(() {
                          tabNumber=5;
                        });
                      },
                    ),*/
                  ],
                ),
              ),

            /// Main Body Part
            Expanded(
              flex: 4,
              child: Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColor.bgColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: getPageWidget(tabNumber)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getPageWidget(int number){
    switch(number){
      case 0:{
        return const EventScreenNavigator();
      }
      case 1:{
        return const CaseOfMonthScreenNavigator();
      }
      case 2:{
        return const UserScreenNavigator();
      }

      // case 4:{
      //   return const SubscriptionPlanNavigator();
      // }
      // case 5:{
      //   return const OkotoProfileScreenNavigator();
      // }
      default : {
        return  const UserScreenNavigator();

      }

    }
  }

}
