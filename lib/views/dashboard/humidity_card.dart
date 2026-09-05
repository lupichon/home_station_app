import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bar_indicator.dart';
import '../widgets/card.dart';
import '../widgets/card_label.dart';
import '../widgets/badge.dart';
import '../../utils/thresholds_handler.dart';

class HumidityCard extends StatelessWidget {
  final double? value;
  const HumidityCard({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    final v = value;
    final (label, color) = v == null
        ? ('–', AppColors.textMuted) : classify(v, humidityThresholds);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppCardLabel(icon: Icons.water_drop_outlined, text: 'Humidité'),
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
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w500,
                            color: AppColors.blue)),
                    const TextSpan(
                        text: '%',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 8),
          AppBarIndicator(
            fraction: v == null ? 0 : (v / 100),
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }
}