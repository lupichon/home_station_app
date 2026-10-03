import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/card.dart';
import '../theme/quality.dart';

class AirScoreCard extends StatelessWidget {
  final double score;

  const AirScoreCard({
    super.key,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final (scoreLabel, scoreColor) = roomScoreQuality(score);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Score ring
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scoreColor, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(score.toStringAsFixed(0),
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: scoreColor)),
                const Text('/ 100',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(scoreLabel,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}