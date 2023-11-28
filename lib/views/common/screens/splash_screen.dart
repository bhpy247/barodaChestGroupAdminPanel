import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/admin/admin_controller.dart';
import '../../../backend/admin/admin_provider.dart';
import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/my_print.dart';
import '../components/common_text.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirst = true;

  late AdminController adminController;
  late AdminProvider adminProvider;

  void loginCheckMethod(BuildContext context)  async {
    NavigationController.isFirst = false;

    await getAppRelatedData();

    await Future.delayed(const Duration(milliseconds:200));


    MyPrint.printOnConsole("In loginCheckMethod");
    bool userLoggedIn = await AuthenticationController().checkUserLoginForFirstTime();
  //   bool userLoggedIn = true;

    if(userLoggedIn)  {
      MyPrint.printOnConsole("User logged in");
      if(context.mounted) {
        NavigationController.navigateToHomePage(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
    }
    else{
      MyPrint.printOnConsole("user not logged in");
      if(context.mounted) {
        NavigationController.navigateToLoginScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
    }
  }

  Future<void> getAppRelatedData() async {
    DateTime start = DateTime.now();
    MyPrint.printOnConsole("getAppRelatedData called");

    await Future.wait([
      adminController.getPropertyDataAndSetInProvider(),
      adminController.getAssetsUploadModelAndSaveInProvider(),
      adminController.getNewTimestampAndSaveInProvider(),
    ]);

    DateTime end = DateTime.now();
    MyPrint.printOnConsole("getAppRelatedData finished in ${start.difference(end).inMilliseconds} Milliseconds");
  }

  @override
  void initState() {
    super.initState();
    adminProvider = Provider.of<AdminProvider>(context, listen: false);
    adminController = AdminController(adminProvider: adminProvider);

    loginCheckMethod(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgSideMenu,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CommonText(
                text: "Baroda Chest Group",
                textAlign: TextAlign.center,
                color: AppColor.yellow,
                fontSize: 100,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
