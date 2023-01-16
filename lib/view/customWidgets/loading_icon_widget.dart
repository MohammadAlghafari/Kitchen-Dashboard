import 'package:flutter/material.dart';
import 'package:thecloud/common/images.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common/colors.dart';

class LoadingIconWidget extends StatefulWidget {
  const LoadingIconWidget({Key? key}) : super(key: key);

  @override
  State<LoadingIconWidget> createState() => _LoadingIconWidgetState();
}

class _LoadingIconWidgetState extends State<LoadingIconWidget> with SingleTickerProviderStateMixin {

  late final AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0.6,
      duration: const Duration(milliseconds: 450),
    );
    WidgetsBinding.instance.addPostFrameCallback(
            (_) => _animationController.repeat(reverse: true));
    super.initState();
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _trans = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _animationController,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    Images.cloudIcon,
                  ),
                  fit: BoxFit.cover
                ),
              ),
            ),
          ),
          Text(_trans.please_wait,
          style: TextStyle(
            color: MyColors.white,
            fontSize: 14.0,
            fontWeight: FontWeight.bold
          ),
          )
        ],
      ),
    );


    //   Center(
    //   child: CircularProgressIndicator(
    //     color: MyColors.green,
    //   ),
    // );
  }
}