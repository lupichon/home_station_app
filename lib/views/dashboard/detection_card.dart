import 'package:flutter/material.dart';
import '../widgets/card.dart';
import '../widgets/status_row.dart';

class DetectionCard extends StatelessWidget {
  final String motionName;
  final bool motionValue;
  final String soundName;
  final bool soundValue;
  final String obstacleName;
  final bool obstacleValue;
  final String vibrationName;
  final bool vibrationValue;
  // gasState retiré, plus besoin ici

  const DetectionCard({
    super.key,
    required this.motionName,
    required this.motionValue,
    required this.soundName,
    required this.soundValue,
    required this.obstacleName,
    required this.obstacleValue,
    required this.vibrationName,
    required this.vibrationValue,
    // gasState retiré des paramètres
  });

  // _gasQuality supprimée (déplacée dans AtmosphericCard)

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppBoolRow(icon: Icons.directions_walk_outlined, label: motionName,
              active: motionValue, onLabel: 'Détecté', offLabel: 'Aucun'),
          AppBoolRow(icon: Icons.volume_up_outlined, label: soundName,
              active: soundValue, onLabel: 'Détecté', offLabel: 'Calme'),
          AppBoolRow(icon: Icons.sensors_outlined, label: obstacleName,
              active: obstacleValue, onLabel: 'Présent', offLabel: 'Aucun'),
          AppBoolRow(icon: Icons.vibration, label: vibrationName,
              active: vibrationValue, onLabel: 'Détectée', offLabel: 'Aucune'),
          // AppStatusRow du gaz supprimée d'ici
        ],
      ),
    );
  }
}