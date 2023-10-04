import 'package:baroda_chest_group_admin/backend/academic_connect/academic_connect_provider.dart';
import 'package:baroda_chest_group_admin/backend/brochure/brochure_provider.dart';
import 'package:baroda_chest_group_admin/backend/committee_member/committee_member_provider.dart';
import 'package:baroda_chest_group_admin/backend/contact_us/contact_us_provider.dart';
import 'package:baroda_chest_group_admin/backend/event_backend/event_provider.dart';
import 'package:baroda_chest_group_admin/backend/guide_line/guideline_provider.dart';
import 'package:baroda_chest_group_admin/backend/member/member_provider.dart';
import 'package:baroda_chest_group_admin/backend/membership_form/membership_form_provider.dart';
import 'package:baroda_chest_group_admin/backend/photo_gallery/photo_gallery_provider.dart';
import 'package:baroda_chest_group_admin/utils/WebPageLoad/web_page_load_non_web.dart';
import 'package:baroda_chest_group_admin/views/common/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'backend/admin/admin_provider.dart';
import 'backend/authentication/authentication_provider.dart';
import 'backend/case_of_month/case_of_month_provider.dart';
import 'backend/common/common_provider.dart';
import 'backend/common/menu_provider.dart';
import 'backend/navigation/navigation_controller.dart';
import 'backend/users_backend/user_provider.dart';
import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();
  checkPageLoad();

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider(), lazy: false),
        ChangeNotifierProvider<AdminProvider>(create: (_) => AdminProvider(), lazy: false),
        ChangeNotifierProvider<CommonProvider>(create: (_) => CommonProvider(), lazy: false),
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider(), lazy: false),
        ChangeNotifierProvider<UserProvider>(create: (_) => UserProvider(), lazy: false),
        ChangeNotifierProvider<EventProvider>(create: (_) => EventProvider(), lazy: false),
        ChangeNotifierProvider<CaseOfMonthProvider>(create: (_) => CaseOfMonthProvider(), lazy: false),
        ChangeNotifierProvider<BrochureProvider>(create: (_) => BrochureProvider(), lazy: false),
        ChangeNotifierProvider<PhotoGalleryProvider>(create: (_) => PhotoGalleryProvider(), lazy: false),
        ChangeNotifierProvider<MemberProvider>(create: (_) => MemberProvider(), lazy: false),
        ChangeNotifierProvider<CommitteeMemberProvider>(create: (_) => CommitteeMemberProvider(), lazy: false),
        ChangeNotifierProvider<GuidelineProvider>(create: (_) => GuidelineProvider(), lazy: false),
        ChangeNotifierProvider<ContactUsProvider>(create: (_) => ContactUsProvider(), lazy: false),
        ChangeNotifierProvider<AcademicConnectProvider>(create: (_) => AcademicConnectProvider(), lazy: false),
        ChangeNotifierProvider<MembershipFormProvider>(create: (_) => MembershipFormProvider(), lazy: false),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: NavigationController.mainScreenNavigator,
        title: "Admin",
        initialRoute: SplashScreen.routeName,
        onGenerateRoute: NavigationController.onMainAppGeneratedRoutes,
        navigatorObservers: const [
          // FirebaseAnalyticsObserver(analytics: firebaseAnalytics),
        ],
      ),
    );
  }
}
