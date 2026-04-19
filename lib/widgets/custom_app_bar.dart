import 'package:flutter/material.dart';
import '../constants/app_styles.dart';
import '../utils/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Color backgroundColor;
  final double elevation;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = AppColors.primary,
    this.elevation = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppStyles.headlineSmall.copyWith(
          color: AppColors.white,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: elevation,
      leading: leading,
      actions: actions,
      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}