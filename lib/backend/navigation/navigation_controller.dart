import 'package:baroda_chest_group_admin/views/caseofmonth/screens/add_case_of_month.dart';
import 'package:baroda_chest_group_admin/views/caseofmonth/screens/case_of_month_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/my_print.dart';
import '../../views/authentication/screens/login_screen.dart';
import '../../views/common/screens/splash_screen.dart';
import '../../views/events/screens/add_Event.dart';
import '../../views/events/screens/event_list_screen.dart';
import '../../views/homescreen/screens/home_page.dart';
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
          page = const CourseListScreen();
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
}
