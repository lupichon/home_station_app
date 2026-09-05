import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSectionLabel extends StatelessWidget {
  final String text;
  const AppSectionLabel(this.text, {super.key});   

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w600,
        ),
      );
}