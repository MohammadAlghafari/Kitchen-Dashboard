import 'package:flutter/material.dart';

import 'colors.dart';

class Themes {
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
      hintColor: Colors.grey,
      scaffoldBackgroundColor: MyColors.backgroundLevel1,
      appBarTheme: AppBarTheme(color: MyColors.backgroundLevel1),
    );
  }

  static ThemeData whiteTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      textTheme: Theme.of(context).textTheme.apply(
            bodyColor: MyColors.black,
            displayColor: MyColors.black,
          ),
      scaffoldBackgroundColor: MyColors.grey,
      hintColor: Colors.grey,
      appBarTheme: AppBarTheme(
        color: MyColors.white,
        iconTheme: IconThemeData(color: MyColors.black),
        toolbarTextStyle: TextStyle(color: MyColors.black),
      ),
    );
  }
}
