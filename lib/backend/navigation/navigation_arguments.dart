
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';

import '../../models/course/data_model/course_model.dart';
import '../../models/event/data_model/event_model.dart';
import '../../models/user/data_model/user_model.dart';

class NavigationArguments {
  const NavigationArguments();
}

class OrderListScreenNavigationArguments extends NavigationArguments {
  bool isFromDeviceScreen = false;

  OrderListScreenNavigationArguments({this.isFromDeviceScreen = false});
}

class AddCourseScreenNavigationArguments extends NavigationArguments {
  EventModel? eventModel;
  bool isEdit = false;
  int? index;

  AddCourseScreenNavigationArguments({this.isEdit = false, this.eventModel, this.index});
}
class AddCaseOfMonthScreenNavigationArguments extends NavigationArguments {
  CaseOfMonthModel? caseOfMonthModel;
  bool isEdit = false;
  int? index;

  AddCaseOfMonthScreenNavigationArguments({this.isEdit = false, this.caseOfMonthModel, this.index});
}

class UserProfileViewScreenNavigationArguments extends NavigationArguments {
  final String userId;
  final UserModel? userModel;

  const UserProfileViewScreenNavigationArguments({
    required this.userId,
    this.userModel,
  });
}
