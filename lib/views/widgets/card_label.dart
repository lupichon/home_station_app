import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCardLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const AppCardLabel({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      );
}