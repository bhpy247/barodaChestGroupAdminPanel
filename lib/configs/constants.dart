import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {
  static const int coursesDocumentLimitForPagination = 10;
  static const int coursesRefreshLimitForPagination = 3;
  static const int userRefreshIndexForPagination = 5;


  String getSecureUrl(String url) {
    if(url.startsWith("http:")) {
      url = url.replaceFirst("http:", "https:");
    }
    return url;
  }
  /// Get these credentials from FirebaseConsole/Project/ProjectSettings/CloudMessaging/Firebase Cloud Messaging API (V1)/Manage Service Accounts/firebaseAdminSdkServiceAccount/keys Tab/AddKey/json
  static Map<String, String> adminSdkServiceAccountCredentials = <String, String>{
    // "type": "service_account",
    // "project_id": "edu-app-bb24b",
    // "private_key_id": "194b62d878fb1e3f825fa77f7eaa8e3d4ddfab01",
    // "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQC8skcclYetmAeE\nCbD/vjAb3Vu+G+fdZirMMaUgysoADsQw8ST2hpcGoPScUbcRoOXO8eT9CdeFQdfn\nUyH2uxRj09R3SIUsSlbslDKiU8GNeVQre2p1Y5eL5XBjMPkLqT7LIe+ToloS/EyE\nc341VjJG7cK8UfD3KnLxyu56EtEDK3UwWfQe6PRey6opda/PB4LNePm8jIBYVVK4\niIOJYXWk2VUkEoGQ8JKTVJiKqPyUHfR/dx9oNE0TIh9510VJenW0tzNDD6liqPFa\nFzj6+v3YdMTfHdeCqSPX+r0/mIVJZV614bSS+MvuxXQonJ3Pl+5jewXmc+f8bpnP\nnVsgT5C3AgMBAAECggEAWKGokz2NKDXTuepPcCCmOkBkOkyjQTQfACCFfnyiGxrU\nfmSWRxF62Ms7ej1LrwUTTHwEYfKAgAAoaGh8+IZxEl7KWmj+3InigGcvzV1n+Yq2\nxWHH5HGuGjDf9Edpg1ewvfsnrAHDK03EpyYUbvsYzIYbRRd8Bqyypu35y+8Qq9qq\nSzwpYj599XHV/sU7EM3GmJa8/rfbkRt9jCHSBAUnU5UCt3cX/Nruqf4gKob3G3B8\nNi+bx2v8I9ELjgH/8+VMDYF7dkC6s6OL9QQsNM3EPN9WeosbsAHOo/qUtzeQHK3N\nrYvrPBDiRQs9mAhF38Q4Zd47tYKjfj5aAQVJoeV56QKBgQD8ops4Zfpk98NDXJmP\nBWS0OPu+ebC8HlATPDw/NWa3XDO52RI0pXFVQP3QB/dB3C2EQ7jufAuZdS0bLK3n\n3T4reEXHYRY7E+hqAU0av548pLDWL7HXaAz2cJp1ikooYEPGpMpNM/yYCCzJAbEg\nYOl0VFPCHVx8sGtHlIQVXmsm7QKBgQC/Nane9ICeBeRfLW9YHZTwvYK3Ivu/oMal\nWtJj/20sIr0OWEAmKp5FhakWj8qSuN/AI4+JfZiVjAiyxshUt23hYLbWcP8Az/wm\nxgXTvkCg8kUW7b9cYWLDw49pN1huY7Sfct6H1GBz4wZBUzrpROqaJIVd815ZQGed\nDJ/7ghSdswKBgHdNvumKVw35Zy/XefjtfhoR0uinhQvBcOU0i+r5p/EtTIwWc5+D\nBZtSHspwCJcEiEYuyRVuZPfqOwvbNKELfQGAQcufEKWDiD0PMj9QgER5Lb1oNp7X\n109F69tYHB8nHrqfNZ3xz/Zn3eZqsx/sRDMYY5mGzhdgJLlf7GQ++3EdAoGAXV5U\n/twh2ghChf9nuX1od03zAH6CtAZMOf5pcg8OPlkQPGr3mCuDcatc7/lzD8Za7DXx\nJ1A/K/dfX/0VYdjYPQ+++GPhAYKOPFjCC62BXZYwCow5v2CGm9VouBYghncFgj7T\nTzxzhOM88LU1tSbD8FUZEtF+JtL+RYAetu/EJWUCgYBTQxjwuT94zFmD3Yxjz7mY\n2T9NSRr+aQMWNQbhG7/q31sW5XLB/x19mhXJieXMtZvajS/FuQsa/omLcUvYp25O\nYdLIJQIsONTT9XE4pwcEHiftixcazcdxBWzElM9MRey8INedRP0uKn1d5urpaZ+k\nxL2QkMkE/i2SmGWQ8zJI4Q==\n-----END PRIVATE KEY-----\n",
    // "client_email": "firebase-adminsdk-ujqn4@edu-app-bb24b.iam.gserviceaccount.com",
    // "client_id": "117110340292843265892",
    // "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    // "token_uri": "https://oauth2.googleapis.com/token",
    // "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    // "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-ujqn4%40edu-app-bb24b.iam.gserviceaccount.com",
    // "universe_domain": "googleapis.com"
  };

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
  static const String editCourse = "editCourse";
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
