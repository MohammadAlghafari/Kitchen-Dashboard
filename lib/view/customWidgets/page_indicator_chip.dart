import 'package:flutter/material.dart';
import 'package:thecloud/common/colors.dart';

class PageIndicatorChip extends StatelessWidget {
  const PageIndicatorChip(
      {Key? key, required this.pageNumber, required this.isSelected, required this.onTap})
      : super(key: key);

  final String pageNumber;
  final bool isSelected;
  final Function onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Chip(
        label: Text(
          pageNumber,
        ),
        backgroundColor: isSelected ? MyColors.green : null,
      ),
    );
  }
}
