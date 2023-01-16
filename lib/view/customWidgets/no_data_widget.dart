import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/colors.dart';
import '../../util/global_functions.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({
    Key? key,
    this.onTap,
    this.content,
  }) : super(key: key);

  final Function()? onTap;
  final String? content;
  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/no_data.png',
              width: isTablet ? 200 : 150,
              height: isTablet ? 200 : 150,
              fit: BoxFit.cover,
            ),
            Text(
              content ?? _trans!.no_data_found,
              style: TextStyle(
                color: MyColors.green,
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _trans!.tap_anywhere_to_relode,
              style: TextStyle(
                fontSize: isTablet ? 19 : 16,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ),
    );
  }
}
