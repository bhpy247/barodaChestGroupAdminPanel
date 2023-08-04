import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyToast{
  static _showToast(BuildContext context, String msg, int duration, Color toastColor, Color textColor) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: toastColor,
      ),
      child: Text(msg, style: TextStyle(color: textColor),),
    );

    FToast fToast = FToast();
    fToast.init(context);

    /*fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: duration ?? 2),
    );*/

    // Custom Toast Position
    fToast.showToast(
      child: toast,
      toastDuration: Duration(seconds: duration),
      positionedToastBuilder: (context, child) {
        return Positioned(
          bottom: 100.0,
          left: 0,
          right: 0,
          child: child,
        );
      },
    );
  }

  static void showError({required BuildContext context, required String msg}) {
    _showToast(context, msg, 2, Colors.red, Colors.white);
  }

  static void showSuccess({required BuildContext context, required String msg}) {
    _showToast(context, msg, 2, Colors.green, Colors.white);
  }

  static void normalMsg({required BuildContext context, required String msg}) {
    ThemeData themeData = Theme.of(context);
    _showToast(context, msg, 2, themeData.colorScheme.primary, Colors.white);
  }

  static void greyMsg({required BuildContext context, required String msg}) {
    ThemeData themeData = Theme.of(context);
    _showToast(context, msg, 2, themeData.colorScheme.onBackground, Colors.white);
  }
}