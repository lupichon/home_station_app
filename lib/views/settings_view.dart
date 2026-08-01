import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/connection_controller.dart';
import '../models/connection_type.dart';
import '../theme/app_theme.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('Connection'),
          const SizedBox(height: 8),
          ...ConnectionType.values.map((type) {
            final isActive = conn.activeType == type;
            final isWifi = type == ConnectionType.wifi;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ConnectionTile(
                type: type,
                isActive: isActive,
                isDisabled: isWifi,
                onTap: isWifi ? null : () => conn.switchTo(type),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _ConnectionTile extends StatelessWidget {
  final ConnectionType type;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _ConnectionTile({
    required this.type,
    required this.isActive,
    required this.isDisabled,
    this.onTap,
  });

  IconData get _icon => switch (type) {
        ConnectionType.lora => Icons.router_outlined,
        ConnectionType.ble  => Icons.bluetooth,
        ConnectionType.wifi => Icons.wifi,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.accentBorder
                : AppColors.surfaceBorder,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _icon,
              size: 20,
              color: isDisabled
                  ? AppColors.textMuted
                  : isActive
                      ? AppColors.accent
                      : AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDisabled
                          ? AppColors.textMuted
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (isDisabled)
                    const Text(
                      'Coming soon',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle,
                  color: AppColors.accent, size: 18),
          ],
        ),
      ),
    );
  }
}