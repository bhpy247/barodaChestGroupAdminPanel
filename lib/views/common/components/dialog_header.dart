import 'package:flutter/material.dart';

import 'common_text.dart';


class DialogHeader extends StatelessWidget {

  String title;
  double fontSize = 24;

   DialogHeader({required this.title,this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CommonText(text: title,fontSize: fontSize,fontWeight: FontWeight.bold),
        InkWell(
            onTap: (){
              Navigator.pop(context);
            },
            child: Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close,color: Colors.black))),
      ],
    );
  }
}
