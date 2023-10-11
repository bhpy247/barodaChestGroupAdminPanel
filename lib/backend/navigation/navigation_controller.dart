import 'package:baroda_chest_group_admin/views/brochure/screens/add_brochure.dart';
import 'package:baroda_chest_group_admin/views/brochure/screens/brochure_list.dart';
import 'package:baroda_chest_group_admin/views/caseofmonth/screens/add_case_of_month.dart';
import 'package:baroda_chest_group_admin/views/caseofmonth/screens/case_of_month_list.dart';
import 'package:baroda_chest_group_admin/views/committeeMember/screens/committee_member_list.dart';
import 'package:baroda_chest_group_admin/views/contact_us/screen/contact_us_screeen.dart';
import 'package:baroda_chest_group_admin/views/guideLine/screen/add_guideline_screen.dart';
import 'package:baroda_chest_group_admin/views/guideLine/screen/guideline_screen.dart';
import 'package:baroda_chest_group_admin/views/photoGallery/screens/add_photo_gallery.dart';
import 'package:baroda_chest_group_admin/views/send_notification/screen/sendNotificationScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/my_print.dart';
import '../../views/academic_connect/screens/academic_connect_list_screen.dart';
import '../../views/academic_connect/screens/add_academic_connect.dart';
import '../../views/authentication/screens/login_screen.dart';
import '../../views/committeeMember/screens/add_committee_member.dart';
import '../../views/common/screens/splash_screen.dart';
import '../../views/events/screens/add_Event.dart';
import '../../views/events/screens/event_list_screen.dart';
import '../../views/homescreen/screens/home_page.dart';
import '../../views/member/screen/add_member.dart';
import '../../views/member/screen/member_list.dart';
import '../../views/membershipForm/screen/memberShip_form_screeen.dart';
import '../../views/photoGallery/screens/photo_gallery_screeen.dart';
import '../../views/users/screens/user_profile_view.dart';
import '../../views/users/screens/users_list_screen.dart';
import 'navigation_arguments.dart';
import 'navigation_operation.dart';
import 'navigation_operation_parameters.dart';

class NavigationController {
  static NavigationController? _instance;
  static String chatRoomId = "";
  static bool isNoInternetScreenShown = false;
  static bool isFirst = true;

  factory NavigationController() {
    _instance ??= NavigationController._();
    return _instance!;
  }

  NavigationController._();

  static final GlobalKey<NavigatorState> mainScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> eventScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> caseOfMonthScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> brochureScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> guidelineScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> contactUsScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> membershipScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> sendNotificationScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> photoGalleryScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> memberScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> committeeMemberScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> academicConnectScreenNavigator = GlobalKey<NavigatorState>();

  // static final GlobalKey<NavigatorState> photoGalleryScreenNavigator = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> userScreenNavigator = GlobalKey<NavigatorState>();

  static bool isUserProfileTabInitialized = false;

  static bool checkDataAndNavigateToSplashScreen() {
    MyPrint.printOnConsole("checkDataAndNavigateToSplashScreen called, isFirst:$isFirst");

    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isFirst = false;
        Navigator.pushNamedAndRemoveUntil(mainScreenNavigator.currentContext!, SplashScreen.routeName, (route) => false);
      });
    }

    return isFirst;
  }

  static Route? onMainAppGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("onAdminMainGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const SplashScreen();
          break;
        }
      case SplashScreen.routeName:
        {
          page = const SplashScreen();
          break;
        }
      case LoginScreen.routeName:
        {
          page = parseLoginScreen(settings: settings);
          break;
        }
      case HomePage.routeName:
        {
          page = parseHomePage(settings: settings);
          break;
        }
      case AddCommitteeMemberScreen.routeName:
        {
          page = parseAddCommitteeMemberScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onEventGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Event Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const EventListScreen();
          break;
        }

      case AddCourse.routeName:
        {
          page = parseAddEventScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onCaseOfMonthGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Case Of month Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const CaseOfMonthList();
          break;
        }

      case AddCaseOfMonthScreen .routeName:
        {
          page = parseAddCaseOfMonthScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onBrochureGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Brochure Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const BrochureListScreen();
          break;
        }

      case AddBrochure.routeName:
        {
          page = parseAddBrochureScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onPhotoGalleryGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("photo Gallery Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const PhotoGalleryScreen();
          break;
        }

      case AddPhotoGalleryScreen.routeName:
        {
          page = parseAddPhotoGalleryScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onMemberGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Member Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const MemberScreen();
          break;
        }

      case AddMemberScreen.routeName:
        {
          page = parseAddMemberScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }
  
  static Route? onCommitteeMemberGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Committee Member Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const CommitteeMemberScreen();
          break;
        }

      case AddCommitteeMemberScreen.routeName:
        {
          page = parseAddCommitteeMemberScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onGuidelineGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Guideline Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const GuideLineScreen();
          break;
        }

      case AddGuideline.routeName:
        {
          page = parseAddGuidelineScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onContactUsScreenRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("On Contact Us Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const ContactUsScreen();
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onMembershipFormScreenRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("On Contact Us Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const MembershipFormScreen();
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onSendNotificationScreenRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("On Contact Us Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const SendNotificationScreen();
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onUserGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Course Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const UserListScreen();
          break;
        }

      case UserProfileView.routeName:
        {
          page = parseUserProfileViewScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onAcademicConnectGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("Event Generated Routes called for ${settings.name} with arguments:${settings.arguments}");

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const AcademicConnectListScreen();
          break;
        }

      case AddAcademicConnect.routeName:
        {
          page = parseAddAcademicConnectScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

//-------------------------------------------------------------------------------------------------------------------------------------------------------------

  //region Parse Page From RouteSettings

  static Widget? parseLoginScreen({required RouteSettings settings}) {
    return const LoginScreen();
  }

  static Widget? parseHomePage({required RouteSettings settings}) {
    return HomePage();
  }

  static Widget? parseAddEventScreen({required RouteSettings settings}) {
    if (settings.arguments is AddCourseScreenNavigationArguments) {
      AddCourseScreenNavigationArguments arguments = settings.arguments as AddCourseScreenNavigationArguments;
      return AddCourse(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }

  static Widget? parseAddAcademicConnectScreen({required RouteSettings settings}) {
    if (settings.arguments is AddAcademicConnectScreenNavigationArguments) {
      AddAcademicConnectScreenNavigationArguments arguments = settings.arguments as AddAcademicConnectScreenNavigationArguments;
      return AddAcademicConnect(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }
  static Widget? parseAddCaseOfMonthScreen({required RouteSettings settings}) {
    if (settings.arguments is AddCaseOfMonthScreenNavigationArguments) {
      AddCaseOfMonthScreenNavigationArguments arguments = settings.arguments as AddCaseOfMonthScreenNavigationArguments;
      return AddCaseOfMonthScreen(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }
  static Widget? parseAddBrochureScreen({required RouteSettings settings}) {
    if (settings.arguments is AddBrochureNavigationArguments) {
      AddBrochureNavigationArguments arguments = settings.arguments as AddBrochureNavigationArguments;
      return AddBrochure(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }
  static Widget? parseAddPhotoGalleryScreen({required RouteSettings settings}) {
    if (settings.arguments is AddPhotoGalleryNavigationArguments) {
      AddPhotoGalleryNavigationArguments arguments = settings.arguments as AddPhotoGalleryNavigationArguments;
      return AddPhotoGalleryScreen(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }

  static Widget? parseAddMemberScreen({required RouteSettings settings}) {
    if (settings.arguments is AddMemberScreenNavigationArguments) {
      AddMemberScreenNavigationArguments arguments = settings.arguments as AddMemberScreenNavigationArguments;
      return AddMemberScreen(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }  
  static Widget? parseAddCommitteeMemberScreen({required RouteSettings settings}) {
    if (settings.arguments is AddCommitteeMemberScreenNavigationArguments) {
      AddCommitteeMemberScreenNavigationArguments arguments = settings.arguments as AddCommitteeMemberScreenNavigationArguments;
      return AddCommitteeMemberScreen(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }
  static Widget? parseAddGuidelineScreen({required RouteSettings settings}) {
    if (settings.arguments is AddGuidelineNavigationArguments) {
      AddGuidelineNavigationArguments arguments = settings.arguments as AddGuidelineNavigationArguments;
      return AddGuideline(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }

  static Widget? parseUserProfileViewScreen({required RouteSettings settings}) {
    if (settings.arguments is UserProfileViewScreenNavigationArguments) {
      UserProfileViewScreenNavigationArguments arguments = settings.arguments as UserProfileViewScreenNavigationArguments;
      return UserProfileView(
        arguments: arguments,
      );
    } else {
      return null;
    }
  }

  //endregion

//------------------------------------------------------------------------------------------------------------------------------------------------------------

  static Future<dynamic> navigateToLoginScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: LoginScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToHomePage({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: HomePage.routeName,
      ),
    );
  }

  static Future<dynamic> navigateToAddCourseScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddCourseScreenNavigationArguments addCourseScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddCourse.routeName,
        arguments: addCourseScreenNavigationArguments,
      ),
    );
  }
  static Future<dynamic> navigateToAddCaseOfMonthScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddCaseOfMonthScreenNavigationArguments addCourseScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddCaseOfMonthScreen.routeName,
        arguments: addCourseScreenNavigationArguments,
      ),
    );
  }
  static Future<dynamic> navigateToAddBrochureScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddBrochureNavigationArguments addBrochureScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddBrochure.routeName,
        arguments: addBrochureScreenNavigationArguments,
      ),
    );
  }
  static Future<dynamic> navigateToAddPhotoGalleryScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddPhotoGalleryNavigationArguments addPhotoGalleryScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddPhotoGalleryScreen.routeName,
        arguments: addPhotoGalleryScreenNavigationArguments,
      ),
    );
  }

  static Future<dynamic> navigateToAddMemberScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddMemberScreenNavigationArguments addMemberScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddMemberScreen.routeName,
        arguments: addMemberScreenNavigationArguments,
      ),
    );
  } 
  static Future<dynamic> navigateToAddCommitteeMemberScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddCommitteeMemberScreenNavigationArguments addMemberScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddCommitteeMemberScreen.routeName,
        arguments: addMemberScreenNavigationArguments,
      ),
    );
  }  
  static Future<dynamic> navigateToAddGuidelineScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddGuidelineNavigationArguments addGuidelineNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddGuideline.routeName,
        arguments: addGuidelineNavigationArguments,
      ),
    );
  }

  static Future<dynamic> navigateToUserProfileViewScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required UserProfileViewScreenNavigationArguments userProfileViewScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: UserProfileView.routeName,
        arguments: userProfileViewScreenNavigationArguments,
      ),
    );
  }

  static Future<dynamic> navigateToAddAcademicConnectScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddAcademicConnectScreenNavigationArguments academicConnectScreenNavigationArguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddAcademicConnect.routeName,
        arguments: academicConnectScreenNavigationArguments,
      ),
    );
  }
}
