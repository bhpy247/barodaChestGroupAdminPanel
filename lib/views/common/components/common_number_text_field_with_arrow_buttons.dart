import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/parsing_helper.dart';

class CommonNumberTextFieldWithArrowButtons extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final double arrowSkipValue;
  final void Function(String)? onChanged;
  final void Function({required double currentValue, required double arrowSkipValue})? onValueIncreased, onValueDecreased;
  final void Function()? setState;

  const CommonNumberTextFieldWithArrowButtons({
    super.key,
    required this.controller,
    this.validator,
    this.arrowSkipValue = 100.0,
    this.onChanged,
    this.onValueIncreased,
    this.onValueDecreased,
    this.setState,
  }) ;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4)
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          // color: AppColor.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                cursorColor: Colors.black,
                textAlign: TextAlign.center,
                validator: validator,
                onChanged: onChanged,
                style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black),
                decoration: const InputDecoration(
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none),
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    double currentValue = ParsingHelper.parseDoubleMethod(controller.text);
                    if(onValueIncreased != null) {
                      onValueIncreased!(currentValue: currentValue, arrowSkipValue: arrowSkipValue);
                    }
                    else {
                      double newPrice = currentValue + arrowSkipValue;
                      controller.text = newPrice.toString();
                      if(setState != null) setState!();
                    }
                  },
                  child: const Icon(
                    Icons.arrow_drop_up,
                    color: AppColor.bgSideMenu,
                  ),
                ),
                InkWell(
                  onTap: () {
                    double currentValue = ParsingHelper.parseDoubleMethod(controller.text);
                    if(onValueDecreased != null) {
                      onValueDecreased!(currentValue: currentValue, arrowSkipValue: arrowSkipValue);
                    }
                    else {
                      if (currentValue >= arrowSkipValue) {
                        double newPrice = currentValue - arrowSkipValue;
                        controller.text = newPrice.toString();
                      }
                      else {
                        controller.text = "0";
                      }
                      if(setState != null) setState!();
                    }
                  },
                  child: const Icon(
                    Icons.arrow_drop_down,
                    color: AppColor.bgSideMenu,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
