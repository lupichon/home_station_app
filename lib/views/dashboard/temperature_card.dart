import 'package:flutter/material.dart';
import '../widgets/bar_indicator.dart';
import '../widgets/card_label.dart';
import '../widgets/card.dart';
import '../widgets/badge.dart';
import '../theme/app_theme.dart';
import '../../utils/thresholds_handler.dart';

class TemperatureCard extends StatelessWidget {
  final double? value;
  const TemperatureCard({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    final v = value;
    final (label, color) = v == null
        ? ('–', AppColors.textMuted) : classify(v, temperatureThresholds);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppCardLabel(icon: Icons.thermostat_outlined, text: 'Temp'),
              const Spacer(),
              AppBadge(label: label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          v == null
              ? const Text('–',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 24))
              : RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: v.toStringAsFixed(1),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: color)),
                    const TextSpan(
                        text: '°C',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 8),
          AppBarIndicator(
            fraction: v == null ? 0 : (v / 50),
            color: v == null ? AppColors.surfaceBorder : color,
          ),
        ],
      ),
    );
  }
}