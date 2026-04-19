import 'package:flutter/material.dart';
import '../utils/status_enums.dart';
import '../constants/app_styles.dart';

class StatusBadge extends StatelessWidget {
  final SaleStatus status;
  final double fontSize;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppStyles.paddingSmall,
        vertical: AppStyles.paddingXSmall,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.2),
        border: Border.all(color: status.color),
        borderRadius: BorderRadius.circular(AppStyles.borderRadiusSmall),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}