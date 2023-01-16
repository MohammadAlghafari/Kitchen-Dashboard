import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../common/colors.dart';
import '../../util/global_functions.dart';

class ServerErrorWidget extends StatelessWidget {
  const ServerErrorWidget({Key? key, this.onTap}) : super(key: key);

  final Function()? onTap;
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
             Icon(
              Icons.error_outline,
              color: MyColors.green,
              size: isTablet ? 150 : 100,
            ),
            Text(
              _trans!.something_went_wrong,
              style: TextStyle(
                color: MyColors.green,
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _trans.tap_anywhere_to_relode,
              style:  TextStyle(
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
