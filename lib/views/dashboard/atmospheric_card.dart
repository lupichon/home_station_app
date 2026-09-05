import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/card.dart';
import '../widgets/badge.dart';
import '../widgets/card_label.dart';  
import '../widgets/bar_indicator.dart';
import '../widgets/status_row.dart';
import '../../utils/thresholds_handler.dart';

class AtmosphericCard extends StatelessWidget {
  final double? co2;
  final double? pressure;
  final double? voc;
  final double? nox;
  final String? gasState;

  const AtmosphericCard({super.key, this.co2, this.pressure, this.voc, this.nox, this.gasState});

  @override
  Widget build(BuildContext context) {
    final (co2Label, co2Color) = co2 == null
        ? ('–', AppColors.textMuted) : classify(co2!, co2Thresholds);
    final (pressLabel, pressColor) = pressure == null
        ? ('–', AppColors.textMuted) : classify(pressure!, pressureThresholds);
    final (vocLabel, vocColor) = voc == null
        ? ('–', AppColors.textMuted) : classify(voc!, vocThresholds);
    final (noxLabel, noxColor) = nox == null
        ? ('–', AppColors.textMuted) : classify(nox!, noxThresholds);
    final (gasLabel, gasColor) = int.tryParse(gasState ?? '') == null
        ? ('–', AppColors.textMuted) : classify(int.parse(gasState!).toDouble(), gasThresholds);

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
                    const AppCardLabel(icon: Icons.eco_outlined, text: 'CO₂'),
                    const SizedBox(height: 6),
                    co2 == null
                        ? const Text('–',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 22))
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: co2!.toStringAsFixed(0),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: co2Color)),
                              const TextSpan(
                                  text: ' ppm',
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
                    const AppCardLabel(icon: Icons.compress, text: 'Pression'),
                    const SizedBox(height: 6),
                    pressure == null
                        ? const Text('–',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 22))
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: pressure!.toStringAsFixed(1),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textPrimary)),
                              const TextSpan(
                                  text: ' hPa',
                                  style: TextStyle(
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
            fraction: co2 == null ? 0 : ((co2! - 400) / 1600),
            color: co2Color,
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('400', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('1000', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('2000 ppm', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),

          // Séparateur VOC/NOx
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(color: AppColors.surfaceBorder, height: 0.5),
          ),

          const AppCardLabel(icon: Icons.air, text: 'VOC / NOx'),
          const SizedBox(height: 10),

          // VOC row
          Row(
            children: [
              const SizedBox(width: 4),
              const Text('VOC',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              voc == null
                  ? const Text('–',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15))
                  : Text(voc!.toStringAsFixed(0),
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
            fraction: voc == null ? 0 : (voc! / 500),
            color: vocColor,
          ),
          const SizedBox(height: 10),

          // NOx row
          Row(
            children: [
              const SizedBox(width: 4),
              const Text('NOx',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(width: 8),
              nox == null
                  ? const Text('–',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 15))
                  : Text(nox!.toStringAsFixed(0),
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
            fraction: nox == null ? 0 : (nox! / 500),
            color: noxColor,
          ),

          // Gaz 
          const SizedBox(height: 14),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 0),
            child: Divider(color: AppColors.surfaceBorder, height: 0.5),
          ),
          const SizedBox(height: 6),
          AppStatusRow(
            icon: Icons.local_fire_department_outlined,
            label: 'Gaz / Fumée',
            statusLabel: gasLabel,
            color: gasColor,
          ),
        ],
      ),
    );
  }
}