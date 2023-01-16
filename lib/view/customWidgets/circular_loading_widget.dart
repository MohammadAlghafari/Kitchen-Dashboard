import 'package:flutter/material.dart';
import 'package:thecloud/util/global_functions.dart';
import '../../common/colors.dart';

class CircularLoadingWidget extends StatelessWidget {
   const CircularLoadingWidget({Key? key, this.progressColor}) : super(key: key);
   final String? progressColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: progressColor != null ? hexColor(progressColor) : MyColors.green,
          strokeWidth: 5,
          backgroundColor: MyColors.white,
        ),
      ),
    );
  }
}