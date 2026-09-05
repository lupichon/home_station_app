import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── StatusRow : ligne icône + label + pill de statut coloré ──────────────────

class AppStatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String statusLabel;
  final Color color;
  final Color? pillBackgroundColor; // permet de personnaliser le fond (voir BoolRow)

  const AppStatusRow({
    super.key,
    required this.icon,
    required this.label,
    required this.statusLabel,
    required this.color,
    this.pillBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pillBackgroundColor ?? color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── BoolRow : cas particulier de StatusRow pour un état booléen ──────────────

class AppBoolRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String onLabel;
  final String offLabel;

  const AppBoolRow({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onLabel,
    required this.offLabel,
  });

  @override
  Widget build(BuildContext context) {
    final pillColor = active ? AppColors.green : AppColors.textMuted;
    final pillBg = active ? AppColors.greenBg : AppColors.surfaceBorder;

    return AppStatusRow(
      icon: icon,
      label: label,
      statusLabel: active ? onLabel : offLabel,
      color: pillColor,
      pillBackgroundColor: pillBg, 
    );
  }
}