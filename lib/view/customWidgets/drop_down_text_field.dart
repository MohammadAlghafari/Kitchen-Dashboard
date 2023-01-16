import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:thecloud/common/colors.dart';

class DropDownTextField extends StatelessWidget {
  const DropDownTextField({
    Key? key,
    required this.hintText,
    required this.handleTap,
    required this.controller,
  }) : super(key: key);
  final String hintText;
  final Function handleTap;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
        child: TextField(
          readOnly: true,
          controller: controller,
          autofocus: false,
          style: const TextStyle(fontSize: kIsWeb? 16: 14),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              left: 10,
              top: 25,
            ),
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 12),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Icon(
                Icons.arrow_drop_down,
                size: 22,
                color: MyColors.green,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: MyColors.green,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: MyColors.green,
              ),
            ),
          ),
          onTap: () => handleTap(),
        ));
  }
}
