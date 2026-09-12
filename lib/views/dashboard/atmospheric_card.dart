import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/card.dart';
import '../widgets/badge.dart';
import '../widgets/card_label.dart';  
import '../widgets/bar_indicator.dart';
import '../../utils/thresholds_handler.dart';

class AtmosphericCard extends StatelessWidget {
  final String? co2Name;
  final double? co2Value;
  final String? co2Unit; 
  final String? pressureName;
  final double? pressureValue;
  final String? pressureUnit; 
  final String? vocName;
  final double? vocValue;
  final String? noxName;
  final double? noxValue;
  final String? gasName;
  final double? gasRawValue;

  const AtmosphericCard({super.key, this.co2Name, this.co2Value, this.co2Unit, 
                                    this.pressureName, this.pressureValue, this.pressureUnit,
                                    this.vocName, this.vocValue,
                                    this.noxName, this.noxValue,
                                    this.gasName, this.gasRawValue});

  @override
  Widget build(BuildContext context) {
    final (co2Label, co2Color) = co2Value == null
        ? ('–', AppColors.textMuted) : classify(co2Value!, co2Thresholds);
    final (pressLabel, pressColor) = pressureValue == null
        ? ('–', AppColors.textMuted) : classify(pressureValue!, pressureThresholds);
    final (vocLabel, vocColor) = vocValue == null
        ? ('–', AppColors.textMuted) : classify(vocValue!, vocThresholds);
    final (noxLabel, noxColor) = noxValue == null
        ? ('–', AppColors.textMuted) : classify(noxValue!, noxThresholds);
    final (gasLabel, gasColor) = gasRawValue == null
        ? ('–', AppColors.textMuted) : classify(gasRawValue!, gasThresholds);

    return AppCard(
      child: Column(
        children: [
          // CO2 + Pression côte à côte
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCardLabel(icon: Icons.eco_outlined, text: co2Name ?? ''),
                    const SizedBox(height: 6),
                    co2Value == null
                        ? const Text('–',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 22))
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: co2Value!.toStringAsFixed(0),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: co2Color)),
                              TextSpan(
                                  text: co2Unit != null ? ' $co2Unit' : '',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ]),
                          ),
                    const SizedBox(height: 4),
                    AppBadge(label: co2Label, color: co2Color),
                  ],
                ),
              ),
              Container(
                width: 0.5,
                height: 60,
                color: AppColors.surfaceBorder,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCardLabel(icon: Icons.compress, text: pressureName ?? ''),
                    const SizedBox(height: 6),
                    pressureValue == null
                        ? const Text('–',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 22))
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: pressureValue!.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              TextSpan(
                                  text: pressureUnit != null ? ' $pressureUnit' : '',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ]),
                          ),
                    const SizedBox(height: 4),
                    AppBadge(label: pressLabel, color: pressColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppBarIndicator(
            fraction: co2Value == null ? 0 : ((co2Value! - 400) / 1600),
            color: co2Color,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('400', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('1000', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('2000 ${co2Unit != null ? ' $co2Unit' : ''}', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),

          // Séparateur VOC/NOx
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.surfaceBorder, height: 0.5),
          ),

          AppCardLabel(icon: Icons.air, text: '${vocName ?? ''} / ${noxName ?? ''}'),
          const SizedBox(height: 10),

          // VOC row
          Row(
            children: [
              const SizedBox(width: 4),
              Text('${vocName ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              vocValue == null
                  ? const Text('–',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15))
                  : Text(vocValue!.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
              const Spacer(),
              AppBadge(label: vocLabel, color: vocColor),
            ],
          ),
          const SizedBox(height: 6),
          AppBarIndicator(
            fraction: vocValue == null ? 0 : (vocValue! / 500),
            color: vocColor,
          ),
          const SizedBox(height: 10),

          // NOx row
          Row(
            children: [
              const SizedBox(width: 4),
              Text('${noxName ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              noxValue == null
                  ? const Text('–',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15))
                  : Text(noxValue!.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
              const Spacer(),
              AppBadge(label: noxLabel, color: noxColor),
            ],
          ),
          const SizedBox(height: 6),
          AppBarIndicator(
            fraction: noxValue == null ? 0 : (noxValue! / 500),
            color: noxColor,
          ),

          // Gaz
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Divider(color: AppColors.surfaceBorder, height: 0.5),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              const SizedBox(width: 4),
              Text('${gasName ?? ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              gasRawValue == null
                  ? const Text('–',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15))
                  : Text(gasRawValue!.toStringAsFixed(0),
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary)),
              const Spacer(),
              AppBadge(label: gasLabel, color: gasColor),
            ],
          ),
          const SizedBox(height: 6),
          AppBarIndicator(
            fraction: gasRawValue == null ? 0 : (gasRawValue! / 2500),
            color: gasColor,
          ),
        ],
      ),
    );
  }
}