import 'package:baroda_chest_group_admin/backend/admin/admin_controller.dart';
import 'package:baroda_chest_group_admin/backend/admin/admin_provider.dart';
import 'package:baroda_chest_group_admin/backend/users_backend/user_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/users_backend/user_provider.dart';
import '../../../models/event/data_model/event_model.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../utils/my_print.dart';

class CreatePdf {
  Future<Uint8List?> generatePdf({List<String> registeredUsrModelList = const [], required UserController userController, required EventModel eventModel}) async {
    List<UserModel> userModelList = [];

    List<UserModel> currentUserModelListInUserListSection = Provider.of<UserProvider>(NavigationController.mainScreenNavigator.currentContext!, listen: false).usersList;
    for (String id in registeredUsrModelList) {
      List<UserModel> userModelListPresent = currentUserModelListInUserListSection.where((element) => element.id == id).toList();
      if (userModelListPresent.isEmpty) {
        UserModel userMode = await userController.getUserFromUserIdFirebase(userId: id);
        userModelList.add(userMode);
      } else {
        userModelList.addAll(userModelListPresent);
      }
    }

    MyPrint.printOnConsole("userModelList: ${userModelList.length}");

    try {
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              pw.Text("${eventModel.title}", style: TextStyle()),
              SizedBox(height: 20),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black),
                children: [
                  pw.TableRow(
                    children: [

                      pw.Expanded(
                        child: pw.Padding(
                          padding: const EdgeInsets.all(5),
                          child: pw.Text("Name"),
                        ),
                      ),
                      pw.Expanded(
                          child: pw.Padding(
                        padding: const EdgeInsets.all(5),
                        child: pw.Text("Mobile"),
                      )),
                    ],
                  ),
                ],
              ),
              pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.black),
                  children: List.generate(
                    userModelList.length,
                    (index) => pw.TableRow(
                      children: [
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const EdgeInsets.all(5),
                            child: pw.Text(userModelList[index].name),
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Padding(
                            padding: const EdgeInsets.all(5),
                            child: pw.Text(userModelList[index].mobileNumber),
                          ),
                        )
                      ],
                    ),
                  ))
            ]);
          },
        ),
      );

      Future<Uint8List> myData = pdf.save();
      MyPrint.printOnConsole("THis is the }");
      return myData;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating PDF File in CreatePdf().generatePdf():$e");
      MyPrint.printOnConsole(s);
      return null;
    }
  }

  pw.Widget getText({required String text, double fontSize = 12, PdfColor? color, pw.FontWeight? fontWeight, pw.TextAlign? textAlign}) {
    return pw.Text(text,
        style: pw.TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
        ),
        textAlign: textAlign);
  }

  pw.Widget getBlueText({String text = "", double fontSize = 15}) {
    return pw.Text(
      text,
      style: pw.TextStyle(fontSize: fontSize, color: PdfColors.blue),
    );
  }

// pw.Widget getAddressRow({required String toAddress,required  String fromAddress}){
//   return pw.Row(
//       mainAxisSize: pw.MainAxisSize.min,
//       children: [
//         pw.Expanded(
//             child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
//               getText(text: "To:", textAlign: pw.TextAlign.left, fontSize: 14),
//               getText(
//                 text: "${AppConstants.stringM19Address}",
//                 textAlign: pw.TextAlign.left,
//               )
//             ])),
//         pw.Expanded(child: pw.Container()),
//         pw.Expanded(
//             child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
//               getText(text: "From:", textAlign: pw.TextAlign.left, fontSize: 14),
//               getText(
//                 text: "$fromAddress",
//                 textAlign: pw.TextAlign.left,
//               )
//             ]
//             )
//           //child: getText(text: "From:\n$fromAddress",textAlign: pw.TextAlign.left,fontWeight: pw.FontWeight.bold)
//         ),
//       ]
//   );
// }
}

class ItemAndTrialModel {
  String sampleName = "";
  String trials = "";

  ItemAndTrialModel({this.sampleName = "", this.trials = ""});
}
