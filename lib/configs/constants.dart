import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {
  static const int coursesDocumentLimitForPagination = 10;
  static const int coursesRefreshLimitForPagination = 3;
  static const int userRefreshIndexForPagination = 5;
  static const String firebaseProjectId = "barodachestgroup-b6b77";



  String getSecureUrl(String url) {
    if(url.startsWith("http:")) {
      url = url.replaceFirst("http:", "https:");
    }
    return url;
  }
  /// Get these credentials from FirebaseConsole/Project/ProjectSettings/CloudMessaging/Firebase Cloud Messaging API (V1)/Manage Service Accounts/firebaseAdminSdkServiceAccount/keys Tab/AddKey/json
  static Map<String, String> adminSdkServiceAccountCredentials = <String, String>{
    "type": "service_account",
    "project_id": "barodachestgroup-b6b77",
    "private_key_id": "c19c052151069888be001e5407f6e767ba70e082",
    "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCzngicfyIJolYi\nEXVCHFxaUCgH5cQaUXu0g5iHYe9aCqSnFZyPfUqF91XGgoOj2zuUjenWQNISmJvX\nsOoTUc9CGcZSD4K9KXCGl7k/IScIwaz/swuz4GWq2Zzo7/raonFx4Idrp5kttdKG\nn9d9OkRbmigShaJosgm3Aq+WeXEf/CjLfoEUAfVVeOotbONpzgbbDXeKERaDnOGD\nOZbGx3yyLnj/UeuCWqIaE69xPm2RHjJfeQQxxPRTDjWFxLWLvgPclOH5K57vxjNC\n5URQpyOXj/rT8tX/W3qRokkkJXMDARsRJ2dA6N/2r9IdkIa2AUIghenrUfNfVftz\nPET+o0uVAgMBAAECggEAS4lVY8MPZG/Ru0gOQPw+VnjJLPEStGK6HGMPPTgReZNq\nRR4QlkOBmK84cmAmzjz/ZGz9/u2Jqupk96Nd/Tv1Zn4CajY9rCGGQgQCkqr1iHgy\nseHxNPdUqjIUC94IZ/PSs6pSKRL1l0SUwars66waXU+KNKfgchkVftJxV13BFkq2\n1C4WsQSVMvT7qoV/8VLiaMPS6UBvbTYDylFb8HQzfu2aI0DLmYgsluKwvG66wE1e\nsjbyWwP4pgv/5npq7m4iLL7gelafKrm5biySbjl3F5ssdveMtGUtqHw3WmRIKFYD\nc92eZPg+TZIIu2I819nHkvPaMzfyalCq9MvlRfCgbQKBgQDurK1EO3DucSVM2C9K\nv9hoO0pVDZWoBGSogEXYiE6NltcC0nXvJE64atKTssDmWvggEKF3jDX0R11EpgBX\naoHRab5HUNcIL8AWdRBaTRT5ijcHcEDMLdugpJDpC1GScKA1/1docrlAEnPLqFh1\nkwx1GSO+GOm3/taAtbTgKpq7owKBgQDAp+NoO0NwLAESQHORQzr6r36puda0Cwte\nW4HWBjhS4e24ivYr4lz2ig+FSb0wk9cvNVRv5jGzUDTRwNL75W0Mg/meoYokP2g+\ncqfn4SYW+3IyOYjuOQetI9ygp9YqmGVWL5c4wDXRRVesm0FyOnDo4zNrud2YatN0\nQw/B60PPZwKBgQDQe9eyNXYVYpJhiKnu0pvXmIr6tq4WoRfINJxOY+qyNaPFXFAW\nQBHfd7hPuiJUVfxODhjtU3XB1yC6mYLM2UVixsqmgxACn6tcMo/BQXnj7H7bKYwA\njsI9leLbHr73exgHcu9IVoZJWJT7vibfNT75fqdBI4Ps7Fc1AQRpl+2nnwKBgQC1\nrFxFCUXB/K0R8hdJD5YJmf6evPGbnKKe2znngrwQZJ8QnHIh1feGQZD7RxsSOQf9\nq5OxZejOSD9W4TfUdHhOChIVpg2nuudppCN0BZwupfT9KcZXpw33Fs9R7JOIXWeK\nS5yV1qOpcXOJAGtJ9ZRN+RqfZolx1qMKisbMPjgW1wKBgQCJqrwggoZHzd4AXfm6\n/RSNKVVkuJLAMuihMToVsvJWexCmQtXMDEE/0ZYkUngIIOhjrlKz5J3wAzWuC679\nyh50OZRaT6BAj7GDvqG7HaglvU5vVgaffWsobR6re8FH/wS5TCEKu6YQE2psVoC6\n/2dxiPOYJNUCia3C4Dc8HeASNw==\n-----END PRIVATE KEY-----\n",
    "client_email": "firebase-adminsdk-j2vkk@barodachestgroup-b6b77.iam.gserviceaccount.com",
    "client_id": "112109508617098292758",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-j2vkk%40barodachestgroup-b6b77.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };

}

class NotificationTopicType {
  static const String admin = "admin";
}

class FirestoreExceptionCodes {
  static const String notFound = "not-found";
}

class FirebaseNodes {
  //region Admin Users Collection

  static const String adminUsersCollection = 'admin_user';

  static MyFirestoreCollectionReference get adminUsersCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.adminUsersCollection,
  );

  static MyFirestoreDocumentReference adminUsersDocumentReference({String? adminUserId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.adminUsersCollection,
    documentId: adminUserId,
  );

  //endregion
  //region Admin
  static const String adminCollection = "admin";

  static MyFirestoreCollectionReference get adminCollectionReference => FirestoreController.collectionReference(
    collectionName: adminCollection,
  );

  static MyFirestoreDocumentReference adminDocumentReference({String? documentId}) => FirestoreController.documentReference(
    collectionName: adminCollection,
    documentId: documentId,
      );

  //region Property Document
  static const String propertyDocument = "property";

  static MyFirestoreDocumentReference get adminPropertyDocumentReference => adminDocumentReference(
        documentId: propertyDocument,
      );

  //endregion

  // region Property Document
  static const String assetsUploadedDocument = "assets";

  static MyFirestoreDocumentReference get assetsUploadedPropertyDocumentReference => adminDocumentReference(
        documentId: assetsUploadedDocument,
      );

  //endregion

  //region Event Collection
  static const String eventCollection = 'events';

  static MyFirestoreCollectionReference get eventCollectionReference => FirestoreController.collectionReference(
        collectionName: FirebaseNodes.eventCollection,
      );

  static MyFirestoreDocumentReference eventsDocumentReference({String? courseId}) => FirestoreController.documentReference(
        collectionName: FirebaseNodes.eventCollection,
        documentId: courseId,
  );
  //endregion
  //
  // region Academic Connect Collection
  static const String academicConnectCollection = 'academic_connect';

  static MyFirestoreCollectionReference get academicConnectCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.academicConnectCollection,
  );

  static MyFirestoreDocumentReference academicConnectDocumentReference({String? academicConnectId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.academicConnectCollection,
    documentId: academicConnectId,
  );
  //endregion


  // region Case of month Collection
  static const String caseOfMonthCollection = 'caseofmonth';

  static MyFirestoreCollectionReference get caseOfMonthCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.caseOfMonthCollection,
  );

  static MyFirestoreDocumentReference caseOfMonthDocumentReference({String? courseId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.caseOfMonthCollection,
    documentId: courseId,
  );
  //endregion
  //
  // region Case of month Collection
  static const String brochureCollection = 'brochure';

  static MyFirestoreCollectionReference get brochureCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.brochureCollection,
  );

  static MyFirestoreDocumentReference brochureDocumentReference({String? courseId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.brochureCollection,
    documentId: courseId,
  );
  //endregion

  //region User
  static const String usersCollection = "users";

  static MyFirestoreCollectionReference get usersCollectionReference => FirestoreController.collectionReference(
    collectionName: usersCollection,
  );

  static MyFirestoreDocumentReference userDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: usersCollection,
    documentId: userId,
  );
  //endregion

  // region Gallery
  static const String galleryCollection = "gallery";

  static MyFirestoreCollectionReference get galleryCollectionReference => FirestoreController.collectionReference(
    collectionName: galleryCollection,
  );

  static MyFirestoreDocumentReference galleryDocumentReference({String? documentId}) => FirestoreController.documentReference(
    collectionName: galleryCollection,
    documentId: documentId,
  );
  //endregion
  // region Gallery
  static const String guidelineCollection = "guidelines";

  static MyFirestoreCollectionReference get guidelineCollectionReference => FirestoreController.collectionReference(
    collectionName: guidelineCollection,
  );

  static MyFirestoreDocumentReference guidelineDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: guidelineCollection,
    documentId: userId,
  );
  //endregion
  // region contactus
  static const String contactUsCollection = "contactus";

  static MyFirestoreCollectionReference get contactUsCollectionReference => FirestoreController.collectionReference(
    collectionName: contactUsCollection,
  );

  static MyFirestoreDocumentReference contactUsDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: contactUsCollection,
    documentId: userId,
  );
  //endregion
  //
  // region membership
  static const String membershipCollection = "membership";

  static MyFirestoreCollectionReference get membershipCollectionReference => FirestoreController.collectionReference(
    collectionName: membershipCollection,
  );

  static MyFirestoreDocumentReference membershipDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: contactUsCollection,
    documentId: userId,
  );
  //endregion
  //
  // region committee Member
  static const String committeeMemberCollection = "committeeMember";

  static MyFirestoreCollectionReference get committeeMemberCollectionReference => FirestoreController.collectionReference(
    collectionName: committeeMemberCollection,
  );

  static MyFirestoreDocumentReference committeeMemberDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: committeeMemberCollection,
    documentId: userId,
  );
  //endregion
  // region Member
  static const String memberCollection = "member";

  static MyFirestoreCollectionReference get memberCollectionReference => FirestoreController.collectionReference(
    collectionName: memberCollection,
  );

  static MyFirestoreDocumentReference memberDocumentReference({String? docId}) => FirestoreController.documentReference(
    collectionName: memberCollection,
    documentId: docId,
  );
  //endregion

  //region Event Collection
  static const String notificationCollection = 'notification';

  static MyFirestoreCollectionReference get notificationCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.notificationCollection,
  );

  static MyFirestoreDocumentReference notificationsDocumentReference({String? courseId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.notificationCollection,
    documentId: courseId,
  );
  //endregion

  //region Timestamp Collection
  static const String timestampCollection = "timestamp_collection";

  static MyFirestoreCollectionReference get timestampCollectionReference => FirestoreController.collectionReference(
    collectionName: timestampCollection,
  );
//endregion
}

//Shared Preference Keys
class SharePreferenceKeys {
  static const String appThemeMode = "themeMode";
}

class NotificationTypes {
  static const String event = "Event";
  static const String guideLine = "GuideLine";
  static const String academicConnect = "Academic Connect";
  static const String caseOfMonth = "Case Of The Month";
  static const String news = "News";
  static const String updatedCaseOfMonth = "updatedCaseOfMonth";
  static const String courseValidityExtended = "courseValidityExtended";
  static const String courseAssigned = "courseAssigned";
  static const String courseExpired = "courseExpired";
}

class UIConstants {
  static const String noUserImageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
}

class AppAssets{

  static const String onBoardingSubImage1 = 'assets/onboarding/onboard_sub_1.png';

  static const String onBoardingSubImage2 = 'assets/onboarding/onboard_sub_2.png';

  static const String onBoardingSubImage3 = 'assets/onboarding/onboard_sub_3.png';

  static const String onBoardingButtonImage1 = 'assets/onboarding/button_1.png';

  static const String onBoardingButtonImage2 = 'assets/onboarding/button_2.png';

  static const String onBoardingButtonImage3 = 'assets/onboarding/button_3.png';

  static const String logo = 'assets/images/logo.png';
  static const String roundLogo = 'assets/images/roundLogo.png';


  static const String background_top = 'assets/images/background_top.png';

  static const String background_ring_top = 'assets/images/ring_topbar.png';

}

class MySharePreferenceKeys {
  static const String isLogin = "isLogin";
}

String ISFIRST = "isfirst";
String LAST_OPENED_TIME = "last_opened_time";

class EventTypes {
  static const String typeAcademic = "Academic";
  static const String typeSocial = "Social";
}

class CommitteeMemberType {
  static String committee = "Committee";
  static String subCommittee = "Sub Committee";
}

class AccountType {
  static String consultant = "Consultant";
  static String student = "Student";
}
