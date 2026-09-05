import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLastUpdatedLabel extends StatelessWidget {
  final DateTime? time;
  const AppLastUpdatedLabel({super.key, this.time});

  @override
  Widget build(BuildContext context) {
    final label = time == null
        ? 'Aucune donnée reçue'
        : 'Mis à jour à ${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}:${time!.second.toString().padLeft(2, '0')}';

    return Center(
      child: Text(label,
          style:
              const TextStyle(fontSize: 11, color: AppColors.textMuted)),
    );
  }
}