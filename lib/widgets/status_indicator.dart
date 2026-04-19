import 'package:flutter/material.dart';
import '../utils/status_enums.dart';

class StatusIndicator extends StatelessWidget {
  final SaleStatus status;
  final double size;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.size = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: status.dotColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: status.color,
          width: 2,
        ),
      ),
    );
  }
}