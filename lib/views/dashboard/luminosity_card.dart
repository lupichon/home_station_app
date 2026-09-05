import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/bar_indicator.dart';
import '../widgets/card.dart';
import '../widgets/card_label.dart';
import '../widgets/badge.dart';
import '../../utils/thresholds_handler.dart';

class LuminosityCard extends StatelessWidget {
  final String? name;
  final double? value;
  final String? unit;
  const LuminosityCard({super.key, this.name, this.value, this.unit});
  
  @override
  Widget build(BuildContext context) {
    final (label, color) = value == null
        ? ('–', AppColors.textMuted) : classify(value!, luminosityThresholds);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppCardLabel(icon: Icons.wb_sunny_outlined, text: name ?? ''),
              const Spacer(),
              AppBadge(label: label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          value == null
              ? const Text('–',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 24))
              : RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: value!.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    TextSpan(
                        text: unit != null ? ' $unit' : '',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 8),
          AppBarIndicator(
            fraction: value == null ? 0 : (value! / 2000),
            gradient: const LinearGradient(
                colors: [AppColors.amber, Color(0xFFFFE599)]),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('1000', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('2000 lux', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}