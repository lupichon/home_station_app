import 'package:flutter/material.dart';
import '../widgets/card.dart';
import '../widgets/status_row.dart';

class DetectionCard extends StatelessWidget {
  final bool motion;
  final bool sound;
  final bool obstacle;
  final bool vibration;
  // gasState retiré, plus besoin ici

  const DetectionCard({
    super.key,
    required this.motion,
    required this.sound,
    required this.obstacle,
    required this.vibration,
    // gasState retiré des paramètres
  });

  // _gasQuality supprimée (déplacée dans AtmosphericCard)

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          AppBoolRow(icon: Icons.directions_walk_outlined, label: 'Mouvement',
              active: motion, onLabel: 'Détecté', offLabel: 'Aucun'),
          AppBoolRow(icon: Icons.volume_up_outlined, label: 'Son',
              active: sound, onLabel: 'Détecté', offLabel: 'Calme'),
          AppBoolRow(icon: Icons.sensors_outlined, label: 'Obstacle',
              active: obstacle, onLabel: 'Présent', offLabel: 'Aucun'),
          AppBoolRow(icon: Icons.vibration, label: 'Vibration',
              active: vibration, onLabel: 'Détectée', offLabel: 'Aucune'),
          // AppStatusRow du gaz supprimée d'ici
        ],
      ),
    );
  }
}