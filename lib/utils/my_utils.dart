import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../backend/common/firestore_controller.dart';
import '../configs/constants.dart';
import '../models/common/data_model/new_document_data_model.dart';
import 'my_print.dart';
import 'my_toast.dart';

class MyUtils {

  static Future<void> copyToClipboard(BuildContext? context, String string) async {
    if(string.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: string));
      if(context != null) {
        MyToast.showSuccess(context: context, msg: "Copied");
      }
    }
  }

  static String getNewId({bool isFromUUuid = true}) {
    if (isFromUUuid) {
      return const Uuid().v1().replaceAll("-", "");
    } else {
      return FirebaseFirestore.instance.collection("sdf").doc().id;
    }
  }

  String getSecureUrl(String url) {
    if(url.startsWith("http:")) {
      url = url.replaceFirst("http:", "https:");
    }
    return url;
  }

  static String getCachedFirebaseImageUrlFromUrl(String url) {
    if(url.startsWith("https://storage.googleapis.com/")) {
      return url;
    }
    else if(url.startsWith("https://firebasestorage.googleapis.com/")) {
      String bucketName = Firebase.app().options.storageBucket ?? "";

      String newUrl = url;

      if(bucketName.isNotEmpty) {
        newUrl = newUrl.replaceAll(newUrl.substring(0, newUrl.indexOf(bucketName)), "https://storage.googleapis.com/");
        newUrl = newUrl.replaceAll("%2F", "/");
        newUrl = newUrl.replaceAll("/o/", "/");
        newUrl = newUrl.substring(0, newUrl.indexOf("?"));
        //MyPrint.printOnConsole("newUrl:${newUrl}");
      }

      return newUrl;
    }
    else {
      return url;
    }
  }

  static String getUniqueIdFromUuid() {
    return const Uuid().v1().replaceAll("-", "");
  }

  static String encodeJson(Object? object) {
    try {
      return jsonEncode(object);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in MyUtils.encodeJson():$e");
      MyPrint.logOnConsole(s);
      return "";
    }
  }

  static dynamic decodeJson(String body) {
    try {
      return jsonDecode(body);
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in MyUtils.decodeJson():$e");
      MyPrint.logOnConsole(s);
      return null;
    }
  }

  static Future<NewDocumentDataModel> getNewDocIdAndTimeStamp({bool isGetTimeStamp = true}) async {
    String docId = FirestoreController.documentReference(
      collectionName: "collectionName",
    ).id;
    Timestamp timestamp = Timestamp.now();

    if (isGetTimeStamp) {
      await FirebaseNodes.timestampCollectionReference.add({"temp_timestamp": FieldValue.serverTimestamp()}).then((DocumentReference<Map<String, dynamic>> reference) async {
        docId = reference.id;

        if (isGetTimeStamp) {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get();
          timestamp = documentSnapshot.data()?['temp_timestamp'];
        }

        reference.delete();
      }).catchError((e, s) {
        // reportErrorToCrashlytics(e, s, reason: "Error in DataController.getNewDocId()");
      });

      if (docId.isEmpty) {
        docId = FirestoreController.documentReference(
          collectionName: "collectionName",
        ).id;
      }
    }

    return NewDocumentDataModel(docId: docId, timestamp: timestamp);
  }

  static void hideShowKeyboard({bool isHide = true}) {
    SystemChannels.textInput.invokeMethod(isHide ? 'TextInput.hide' : 'TextInput.show');
  }

  static bool isValidMobileNumber(String mobileNumber) {
    RegExp exp = RegExp(r"^\s*(?:\+?(\d{1,3}))?([-. (]*(\d{3})[-. )]*)?((\d{3})[-. ]*(\d{2,4})(?:[-.x ]*(\d+))?)\s*$");

    return exp.hasMatch(mobileNumber);
  }

  static Future<void> launchWhatsAppChat({required String mobileNumber, String message = ""}) async {
    MyPrint.printOnConsole("launchWhatsAppChat called with mobileNumber:$mobileNumber");

    if(mobileNumber.isEmpty || !isValidMobileNumber(mobileNumber)) {
      MyPrint.printOnConsole("Mobile Number is Empty or Invalid");
      return;
    }

    String urlString = "https://wa.me/$mobileNumber?text=${Uri.encodeComponent(message)}";
    MyPrint.printOnConsole("urlString:$urlString");

    await launchUrlString(url: urlString);
  }

  static Future<void> launchCallMobileNumber({required String mobileNumber}) async {
    MyPrint.printOnConsole("launchCallMobileNumber called with mobileNumber:$mobileNumber");

    if(mobileNumber.isEmpty || !isValidMobileNumber(mobileNumber)) {
      MyPrint.printOnConsole("Mobile Number is Empty or Invalid");
      return;
    }

    String urlString = "tel://$mobileNumber";
    MyPrint.printOnConsole("urlString:$urlString");

    await launchUrlString(url: urlString);
  }

  static Future<void> launchUrlString({required String url, LaunchMode launchMode = LaunchMode.externalApplication}) async {
    MyPrint.printOnConsole("launchUrlString called with:$url");

    Uri? uri = Uri.tryParse(url);

    if(uri != null) {
      try {
        await launchUrl(uri, mode:launchMode);
      }
      catch(e, s) {
        MyPrint.printOnConsole("Error in launching url $url in launchUrlString():$e");
        MyPrint.printOnConsole(s);
      }
    }
    else {
      MyPrint.printOnConsole("Uri is Null");
    }
  }

  static String formatAmountInString(double amount) {
    NumberFormat formatter = NumberFormat('##,##,##,##,##,###');
    return formatter.format(amount);
  }

  String getStorageUploadImageUrl({required String nativeImageName}){
    int dotIndex = 0;
    dotIndex = nativeImageName.lastIndexOf('.');
    String finalImageUrl = nativeImageName.substring(dotIndex);
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    return '$currentTime$finalImageUrl';
  }

  static Color convertStringToColor(String colorString){
    String valueString = colorString.split('(0x')[1].split(')')[0]; // kind of hacky..
    int value = int.parse(valueString, radix: 16);
    return Color(value);
  }

  static String convertColorToString(Color color){
    return color.toString();
  }

}















