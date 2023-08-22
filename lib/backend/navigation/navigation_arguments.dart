
import 'package:baroda_chest_group_admin/models/brochure/data_model/brochure_model.dart';
import 'package:baroda_chest_group_admin/models/caseofmonth/data_model/case_of_month_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/committee_member_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/gallery_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/guideline_model.dart';
import 'package:baroda_chest_group_admin/models/profile/data_model/member_model.dart';

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
class AddBrochureNavigationArguments extends NavigationArguments {
  BrochureModel? brochureModel;
  bool isEdit = false;
  int? index;

  AddBrochureNavigationArguments({this.isEdit = false, this.brochureModel, this.index});
}

class AddGuidelineNavigationArguments extends NavigationArguments {
  GuidelineModel? guidelineModel;
  bool isEdit = false;
  int? index;

  AddGuidelineNavigationArguments({this.isEdit = false, this.guidelineModel, this.index});
}

class AddPhotoGalleryNavigationArguments extends NavigationArguments {
  GalleryModel? galleryModel;
  bool isEdit = false;
  int? index;

  AddPhotoGalleryNavigationArguments({this.isEdit = false, this.galleryModel, this.index});
}
class AddMemberScreenNavigationArguments extends NavigationArguments {
  MemberModel? memberModel;
  bool isEdit = false;
  int? index;

  AddMemberScreenNavigationArguments({this.isEdit = false, this.memberModel, this.index});
}

class AddCommitteeMemberScreenNavigationArguments extends NavigationArguments {
  CommitteeMemberModel? committeeMemberModel;
  bool isEdit = false;
  int? index;

  AddCommitteeMemberScreenNavigationArguments({this.isEdit = false, this.committeeMemberModel, this.index});
}

class UserProfileViewScreenNavigationArguments extends NavigationArguments {
  final String userId;
  final UserModel? userModel;

  const UserProfileViewScreenNavigationArguments({
    required this.userId,
    this.userModel,
  });
}
