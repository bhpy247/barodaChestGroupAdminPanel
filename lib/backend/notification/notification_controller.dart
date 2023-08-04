import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../../configs/constants.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class NotificationController {
  static String serverkey = "AAAAl1_4njI:APA91bEIalQmtqk-UCoyhcAMSiUjf8QczM-bHdoWxYsJ-GA1qXhEGmTogFAT0hyX3KPahNL7IJIF5oUfCcS9FxiRyroSs3Vf16z9jHHOuskD055V0lvcRBa1E62surF0ZXl5WEDQx-8v";
  static String serveruser = "650150190642";

  /// Will Not Work in Web, will face cors policy issue, so use [sendNotificationMessage2] instead for web platform
  static Future<void> sendNotification({
    required String topic,
    String objectid = "",
    String title = "",
    String description = "",
    String type = "",
    String imageurl = "",
    String link = "",
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole(
        "NotificationController().sendNotification() called with topic:'$topic', objectid:'$objectid', title:'$title', description:'$description', type:'$type', imageurl:'$imageurl', link:'$link'",
        tag: tag);

    String url = 'https://fcm.googleapis.com/fcm/send';
    Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverkey',
      // 'Authorization': 'key=BDBTGC-sOo4TNVlF3YaVcOFTs_JkPT2MHvyLdvwCTq5I2L9WT2Il6AlRBgALqZu4UR5x5StNWng1rW9_YMvOTdk',
      'Sender': 'id=$serveruser',
      "Access-Control-Allow-Origin": "*"
    };
    String body = jsonEncode(
      <String, dynamic>{
        'notification': <String, dynamic>{'body': description, 'title': title},
        'priority': 'high',
        'data': <String, dynamic>{
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'id': '1',
          'objectid': objectid,
          'title': title,
          'description': description,
          'type': type,
          'imageurl': imageurl,
        },
        'to': '/topics/$topic',
      },
    );

    try {
      MyPrint.printOnConsole("Url:'$url'", tag: tag);
      MyPrint.printOnConsole("headers:'$headers'", tag: tag);
      MyPrint.printOnConsole("body:'$body'", tag: tag);

      http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      MyPrint.printOnConsole("Response Status:${response.statusCode}", tag: tag);
      MyPrint.printOnConsole("Response Body:${response.body}", tag: tag);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in NotificationController().sendNotification():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  static Future<AccessToken?> getAccessToken() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(AppConstants.adminSdkServiceAccountCredentials);
    var scopes = ["https://www.googleapis.com/auth/firebase.messaging"];

    AuthClient client = await clientViaServiceAccount(accountCredentials, scopes);
    client.close();
    return client.credentials.accessToken;
  }

  static Future<void> sendNotificationMessage2({
    required String title,
    required String description,
    String image = "",
    String token = "",
    String topic = "",
    required Map<String, dynamic> data,
    String tag = "",
    String collapseKey = "",
  }) async {
    MyPrint.printOnConsole("Send Notification Called");
    MyPrint.printOnConsole("Token:$token");

    try {
      //Notification------------------------------------------------------------------------------------------
      Map<String, dynamic> notificationMap = {'title': title, 'body': description};
      //if(tag != null && tag.isNotEmpty) notificationMap['tag'] = tag;
      if (image.isNotEmpty) notificationMap['image'] = image;
      //Notification------------------------------------------------------------------------------------------

      //Android Configs----------------------------------------------------------------------------------------
      Map<String, dynamic> androidConfig = {};
      if (collapseKey.isNotEmpty) androidConfig['collapse_key'] = collapseKey;

      Map<String, dynamic> androidNotifications = {};
      if (tag.isNotEmpty) androidNotifications["tag"] = tag;
      androidNotifications["default_sound"] = true;
      androidNotifications["default_vibrate_timings"] = true;
      androidNotifications["default_light_settings"] = true;
      androidNotifications["notification_count"] = 1;
      if (androidNotifications.isNotEmpty) androidConfig['notification'] = androidNotifications;
      //Android Configs----------------------------------------------------------------------------------------

      //Ios Configs--------------------------------------------------------------------------------------------
      Map<String, dynamic> apnsConfig = {};

      Map<String, dynamic> headers = {};
      headers['apns-push-type'] = "alert";
      headers['apns-priority'] = "10";
      if (headers.isNotEmpty) apnsConfig["headers"] = headers;

      Map<String, dynamic> payload = {};
      payload['aps'] = {
        "content-available": 1,
        "sound": "default",
      };
      if (tag.isNotEmpty) payload['messageID'] = tag;
      if (payload.isNotEmpty) apnsConfig["payload"] = payload;
      //Ios Configs--------------------------------------------------------------------------------------------

      AccessToken? accessToken = await getAccessToken();
      if (accessToken == null || accessToken.data.isEmpty || accessToken.type.isEmpty) return;

      var url = 'https://fcm.googleapis.com/v1/projects/edu-app-bb24b/messages:send';
      var header = {
        "Content-Type": "application/json",
        "Authorization": "${accessToken.type} ${accessToken.data}",
      };

      Map<String, dynamic> message = {
        'notification': notificationMap,
        "android": androidConfig,
        "apns": apnsConfig,
        'data': data,
      };
      if (token.isNotEmpty) {
        message['token'] = token;
      }
      if (topic.isNotEmpty) {
        message['topic'] = topic;
      }

      Map<String, dynamic> request = {
        "message": message,
      };

      var client = Client();
      Uri uri = Uri.parse(url);

      MyPrint.printOnConsole("Request Url:$url");
      MyPrint.printOnConsole("Request Header:$header");
      MyPrint.printOnConsole("Request Payload:${jsonEncode(request)}");

      var response = await client.post(uri, headers: header, body: json.encode(request));
      MyPrint.printOnConsole("Send Notification Response:${response.body}");
      // return true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Sending Notification 2:$e");
      MyPrint.printOnConsole(s);
      // AnalyticsController().recordError(e, s, reason: "Error in Sending Push Notification 2");
    }
  }
}
