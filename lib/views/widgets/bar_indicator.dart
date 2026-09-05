import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppBarIndicator extends StatelessWidget {
  final double fraction;
  final Color? color;
  final Gradient? gradient;

  const AppBarIndicator({super.key, required this.fraction, this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            width: constraints.maxWidth * fraction.clamp(0, 1),
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    });
  }
}