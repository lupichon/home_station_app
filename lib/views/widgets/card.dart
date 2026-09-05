import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatelessWidget {                    // 1. _Card → AppCard (public, sans underscore)
  final Widget child;
  const AppCard({super.key, required this.child});         // 2. ajout de super.key (bonne pratique pour un widget public/réutilisable)

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: child,
      );
}