import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';

import '../../utils/my_print.dart';

class FireBaseStorageController {
  Future<String?> uploadFilesToFireBaseStorage({
    required Uint8List data,
    required String eventId,
    required String fileName,
  }) async {
    String? imageUrl;

    try {
      String? mimeType = lookupMimeType(fileName); // 'image/jpeg'

      final storageRef = FirebaseStorage.instance.ref("event/").child("$eventId/$fileName");
      await storageRef.putData(data, SettableMetadata(contentType: mimeType));
      imageUrl = await storageRef.getDownloadURL();
      return imageUrl;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Firebase Storage Controller in Upload File Method $e");
      MyPrint.printOnConsole(s);
      return imageUrl;
    }
  }

  Future<void> removeFilesToFireBaseStorage({required String courseId, required String fileName}) async {
    try {
      final storageRef = FirebaseStorage.instance.ref("courses/").child("$courseId/$fileName");
      await storageRef.delete();
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Firebase Storage Controller in Delete File Method $e");
      MyPrint.printOnConsole(s);
    }
  }
}
