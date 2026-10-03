import 'package:flutter/material.dart';
import '../../utils/thresholds.dart';
import 'app_theme.dart';

// Colors
const lowColor      = AppColors.blue;
const goodColor     = AppColors.green;
const moderateColor = AppColors.amber;
const badColor      = AppColors.red;

// Labels
const lowLabel              = 'Basse';
const goodLabel             = 'Bon';
const normalLabel           = 'Normal';
const lowLabel2             = 'Faible';
const moderateLabel         = 'Modéré';
const elevatedLabel         = 'Élevé';
const highLabel             = 'Haute';
const veryHighLabel         = 'Très haute';
const dangerLabel           = 'Danger';
const darkLabel             = 'Sombre';
const brightLabel           = 'Lumineux';
const goodQualityLabel      = 'Bonne qualité';
const moderateQualityLabel  = 'Qualité moyenne';
const degradedQualityLabel  = 'Dégradée';
const poorQualityLabel      = 'Mauvaise';

typedef Quality = (String label, Color color);

class Threshold {
  final double max; // borne supérieure (exclusive) ; la dernière entrée sert de "sinon"
  final String label;
  final Color color;
  const Threshold(this.max, this.label, this.color);
}

Quality classify(double value, List<Threshold> thresholds) {
  for (final t in thresholds) {
    if (value < t.max) return (t.label, t.color);
  }
  return (thresholds.last.label, thresholds.last.color);
}

// ─── Tables de seuils (labels courts, sans préfixe capteur) ───────────────────

final co2Thresholds = [
  const Threshold(co2Low,      goodLabel,     goodColor),
  const Threshold(co2Moderate, moderateLabel, moderateColor),
  const Threshold(co2Elevated, elevatedLabel, badColor),
];

final vocThresholds = [
  const Threshold(vocLow,      goodLabel,     goodColor),
  const Threshold(vocModerate, moderateLabel, moderateColor),
  const Threshold(vocElevated, elevatedLabel, badColor),
];

final noxThresholds = [
  const Threshold(noxLow,      goodLabel,     goodColor),
  const Threshold(noxModerate, moderateLabel, moderateColor),
  const Threshold(noxElevated, elevatedLabel, badColor),
];

final pressureThresholds = [
  const Threshold(pressureLow,      lowLabel,     lowColor),
  const Threshold(pressureNormal,   normalLabel,  goodColor),
  const Threshold(pressureHigh,     highLabel,    moderateColor),
  const Threshold(pressureVeryHigh, veryHighLabel,badColor),
];

final luminosityThresholds = [
  const Threshold(luminosityDark,     darkLabel,  AppColors.textMuted),
  const Threshold(luminosityLowLight, lowLabel2,  AppColors.textSecondary),
  const Threshold(luminosityNormal,   normalLabel,goodColor),
  const Threshold(luminosityBright,   brightLabel,moderateColor),
];

final gasThresholds = [
  const Threshold(gasGood,     goodLabel,     goodColor),                
  const Threshold(gasModerate, moderateLabel, moderateColor),       
  const Threshold(gasElevated, elevatedLabel, badColor),             
  const Threshold(gasDanger,   dangerLabel,   badColor),  
];

final temperatureThresholds = [
  const Threshold(temperatureLow,      lowLabel,     lowColor),
  const Threshold(temperatureNormal,   normalLabel,  goodColor),
  const Threshold(temperatureHigh,     highLabel,    moderateColor),
  const Threshold(temperatureVeryHigh, highLabel,    badColor),
];

final humidityThresholds = [
  const Threshold(humidityLow,      lowLabel,     lowColor),
  const Threshold(humidityNormal,   normalLabel,  goodColor),
  const Threshold(humidityHigh,     highLabel,    moderateColor),
  const Threshold(humidityVeryHigh, highLabel,    badColor),
];

Quality roomScoreQuality(double score) {
  if (score >= 80) return ('Confortable', AppColors.green);
  if (score >= 60) return ('Correct', AppColors.amber);
  if (score >= 40) return ('Dégradé', AppColors.red);
  return ('Inconfortable', AppColors.red);
}
