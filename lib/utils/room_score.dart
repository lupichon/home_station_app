import 'thresholds_handler.dart';
import '../views/theme/app_theme.dart';
import 'gas_state.dart' as gas_state;


const hardMinTemp = 12.0;
const goodMinTemp = 20.0;
const goodMaxTemp = 26.0;
const hardMaxTemp = 32.0;

const hardMinHumidity = 15.0;
const goodMinHumidity = 30.0;
const goodMaxHumidity = 60.0;
const hardMaxHumidity = 80.0;

const co2VeryLowScore = 100.0;
const co2LowScore = 90.0;
const co2ModerateScore = 55.0;
const co2ElevatedScore = 15.0;
const co2HighScore = 0.0; 

const vocVeryLowScore = 100.0;
const vocLowScore = 90.0;
const vocModerateScore = 55.0;
const vocElevatedScore = 15.0;
const vocHighScore = 0.0;

const noxVeryLowScore = 100.0;
const noxLowScore = 90.0;
const noxModerateScore = 55.0;
const noxElevatedScore = 15.0;
const noxHighScore = 0.0;

const gasLowScore = 100.0;
const gasModerateScore = 70.0;
const gasElevatedScore = 40.0;
const gasDangerScore = 10.0;

const tempWeight     = 0.20;
const humidityWeight = 0.15;
const co2Weight      = 0.25;
const vocWeight      = 0.15;
const noxWeight      = 0.10;
const gasWeight      = 0.15;

// ─── Interpolation linéaire par morceaux ───────────────────────────────────

/// Interpole un score entre une liste de points (x croissant, y = score 0-100).
/// En dehors des bornes, la valeur est clampée au premier/dernier point.
double _piecewiseLinear(double value, List<(double x, double y)> points) {
  if (value <= points.first.$1) return points.first.$2;
  if (value >= points.last.$1) return points.last.$2;

  for (int i = 0; i < points.length - 1; i++) {
    final (x1, y1) = points[i];
    final (x2, y2) = points[i + 1];
    if (value >= x1 && value <= x2) {
      final t = (value - x1) / (x2 - x1);
      return y1 + t * (y2 - y1);
    }
  }
  return points.last.$2;
}

/// Score trapézoïdal : plateau à 100 entre [goodMin, goodMax],
/// décroît linéairement vers 0 jusqu'à [hardMin, hardMax].
double trapezoidScore(double value, double hardMin, double goodMin, double goodMax, double hardMax) {
  if (value <= hardMin || value >= hardMax) return 0;
  if (value < goodMin) return (value - hardMin) / (goodMin - hardMin) * 100;
  if (value > goodMax) return (hardMax - value) / (hardMax - goodMax) * 100;
  return 100;
}

// ─── Scores continus par facteur ────────────────────────────────────────────

// Confort thermique (zone ASHRAE 55 élargie)
double tempScore(double t) => trapezoidScore(t, hardMinTemp, goodMinTemp, goodMaxTemp, hardMaxTemp);

// Confort hygrométrique (zone ASHRAE 55 élargie)
double humidityScore(double h) => trapezoidScore(h, hardMinHumidity, goodMinHumidity, goodMaxHumidity, hardMaxHumidity);

double co2Score(double v) => _piecewiseLinear(v, [
  (co2VeryLow , co2VeryLowScore),
  (co2Low     , co2LowScore),
  (co2Moderate, co2ModerateScore),
  (co2Elevated, co2ElevatedScore),
  (co2High    , co2HighScore),
]);

double vocScore(double v) => _piecewiseLinear(v, [
  (vocVeryLow , vocVeryLowScore),
  (vocLow     , vocLowScore),
  (vocModerate, vocModerateScore),
  (vocElevated, vocElevatedScore),
  (vocHigh    , vocHighScore),
]);

double noxScore(double v) => _piecewiseLinear(v, [
  (noxVeryLow , noxVeryLowScore),
  (noxLow     , noxLowScore),
  (noxModerate, noxModerateScore),
  (noxElevated, noxElevatedScore),
  (noxHigh    , noxHighScore),
]);

double gasScore(int code) => _piecewiseLinear(code.toDouble(), [
  (gas_state.gasGood.toDouble(),     gasLowScore),
  (gas_state.gasModerate.toDouble(), gasModerateScore),
  (gas_state.gasElevated.toDouble(), gasElevatedScore),
  (gas_state.gasDanger.toDouble(),   gasDangerScore),
]);

// ─── Score global de la pièce ───────────────────────────────────────────────

double computeRoomScore({
  double? temperature,
  double? humidity,
  double? co2,
  double? voc,
  double? nox,
  String? gasState,
}) {
  double weightedSum = 0;
  double usedWeight = 0;

  if (temperature != null) {
    weightedSum += tempScore(temperature) * tempWeight;
    usedWeight += tempWeight;
  }

  if (humidity != null) {
    weightedSum += humidityScore(humidity) * humidityWeight;
    usedWeight += humidityWeight;
  }

  if (co2 != null) {
    weightedSum += co2Score(co2) * co2Weight;
    usedWeight += co2Weight;
  }

  if (voc != null) {
    weightedSum += vocScore(voc) * vocWeight;
    usedWeight += vocWeight;
  }

  if (nox != null) {
    weightedSum += noxScore(nox) * noxWeight;
    usedWeight += noxWeight;
  }

  final gasCode = int.tryParse(gasState ?? '');
  if (gasCode != null) {
    weightedSum += gasScore(gasCode) * gasWeight;
    usedWeight += gasWeight;
  }

  if (usedWeight == 0) return 100; // aucune donnée disponible : valeur neutre

  final weightedAvg = weightedSum / usedWeight;

  return weightedAvg.clamp(0, 100);
}

Quality roomScoreQuality(double score) {
  if (score >= 80) return ('Confortable', AppColors.green);
  if (score >= 60) return ('Correct', AppColors.amber);
  if (score >= 40) return ('Dégradé', AppColors.red);
  return ('Inconfortable', AppColors.red);
}