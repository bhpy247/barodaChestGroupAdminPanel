import '../../utils/my_utils.dart';
import '../../utils/parsing_helper.dart';

class PropertyModel {
  String aboutUs = "",
      supportPhoneNo = "",
      supportEmailId = "",
      quote = "",
      quoteAuthor = "",
      fisCallUs = "",
      fisChatWithUs = "",
      fisWebsite = "",
      downloadNowButtonText = "",
      downloadPageDescription = "",
      caseOfMonthUrl = "",
      headLineText = "";

  List<String> sliders = [];
  List<String> aimsAndObjective = [];

  PropertyModel(
      {this.aboutUs = "",
      this.supportPhoneNo = "",
      this.supportEmailId = "",
      this.downloadNowButtonText = "",
      this.downloadPageDescription = "",
      this.quote = "",
      this.quoteAuthor = "",
      this.sliders = const [],
      this.aimsAndObjective = const [],
      this.fisCallUs = "",
      this.caseOfMonthUrl = "",
      this.headLineText = "",
      this.fisChatWithUs = "",
      this.fisWebsite = ""});

  PropertyModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    sliders = ParsingHelper.parseListMethod<dynamic, String>(map['sliders']);
    aimsAndObjective = ParsingHelper.parseListMethod<dynamic, String>(map['aimsAndObjective']);
    aboutUs = ParsingHelper.parseStringMethod(map['aboutUs']);
    supportPhoneNo = ParsingHelper.parseStringMethod(map['supportPhoneNo']);
    supportEmailId = ParsingHelper.parseStringMethod(map['supportEmailId']);
    fisWebsite = ParsingHelper.parseStringMethod(map['fisWebsite']);
    fisChatWithUs = ParsingHelper.parseStringMethod(map['fisChatWithUs']);
    fisCallUs = ParsingHelper.parseStringMethod(map['fisCallUs']);
    quote = ParsingHelper.parseStringMethod(map['quote']);
    caseOfMonthUrl = ParsingHelper.parseStringMethod(map['caseOfMonthUrl']);
    headLineText = ParsingHelper.parseStringMethod(map['headLineText']);
    quoteAuthor = ParsingHelper.parseStringMethod(map['quoteAuthor']);
    downloadNowButtonText = ParsingHelper.parseStringMethod(map['downloadNowButtonText']);
    downloadPageDescription = ParsingHelper.parseStringMethod(map['downloadPageDescription']);
    quoteAuthor = ParsingHelper.parseStringMethod(map['quoteAuthor']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "sliders": sliders,
      "aimsAndObjective": aimsAndObjective,
      "aboutUs": aboutUs,
      "fisChatWithUs": fisChatWithUs,
      "fisWebsite": fisWebsite,
      "fisCallUs": fisCallUs,
      "supportPhoneNo": supportPhoneNo,
      "caseOfMonthUrl": caseOfMonthUrl,
      "headLineText": headLineText,
      "supportEmailId": supportEmailId,
      "downloadNowButtonText": downloadNowButtonText,
      "downloadPageDescription": downloadPageDescription,
      "quote": quote,
      "quoteAuthor": quoteAuthor,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}

class AssetsUploadModel {
  String webHomeBannerAsset = "";
  String cmeBrochure = "";
  String photoGallery = "";
  String caseOfMonth = "";
  String membershipBanner = "";
  String aimsAndObjectiveImage = "";
  String pastEvent = "";
  String upcomingEvent = "";
  String contactUs = "";
  String guideLine = "";

  AssetsUploadModel({
    this.webHomeBannerAsset = "",
    this.guideLine = "",
    this.caseOfMonth = "",
    this.cmeBrochure = "",
    this.aimsAndObjectiveImage = "",
    this.membershipBanner = "",
    this.contactUs = "",
    this.pastEvent = "",
    this.photoGallery = "",
    this.upcomingEvent = "",
  });

  AssetsUploadModel.fromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    _initializeFromMap(map);
  }

  void _initializeFromMap(Map<String, dynamic> map) {
    webHomeBannerAsset = ParsingHelper.parseStringMethod(map['webHomeBannerAsset']);
    guideLine = ParsingHelper.parseStringMethod(map['guideLine']);
    caseOfMonth = ParsingHelper.parseStringMethod(map['caseOfMonth']);
    cmeBrochure = ParsingHelper.parseStringMethod(map['cmeBrochure']);
    aimsAndObjectiveImage = ParsingHelper.parseStringMethod(map['aimsAndObjectiveImage']);
    membershipBanner = ParsingHelper.parseStringMethod(map['membershipBanner']);
    contactUs = ParsingHelper.parseStringMethod(map['contactUs']);
    pastEvent = ParsingHelper.parseStringMethod(map['pastEvent']);
    photoGallery = ParsingHelper.parseStringMethod(map['photoGallery']);
    upcomingEvent = ParsingHelper.parseStringMethod(map['upcomingEvent']);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "webHomeBannerAsset": webHomeBannerAsset,
      "guideLine": guideLine,
      "caseOfMonth": caseOfMonth,
      "cmeBrochure": cmeBrochure,
      "aimsAndObjectiveImage": aimsAndObjectiveImage,
      "membershipBanner": membershipBanner,
      "contactUs": contactUs,
      "pastEvent": pastEvent,
      "photoGallery": photoGallery,
      "upcomingEvent": upcomingEvent,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}
