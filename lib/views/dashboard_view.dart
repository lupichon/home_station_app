import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/connection_controller.dart';
import '../controllers/sensor_controller.dart';
import '../models/sensor_model.dart';
import '../theme/app_theme.dart';
import 'settings_view.dart';

// ─── Score qualité air ────────────────────────────────────────────────────────

int _computeAirScore({
  double? co2,
  double? voc,
  double? nox,
  String? gasState,
}) {
  int score = 100;
  if (co2 != null) {
    if (co2 > 2000) {
      score -= 30;
    } else if (co2 > 1000) {
      score -= 20;
    } else if (co2 > 600) {
      score -= 10;
    }
  }
  if (voc != null) {
    if (voc > 200) {
      score -= 25;
    } else if (voc > 150) {
      score -= 15;
    } else if (voc > 100) {
      score -= 8;
    }
  }
  if (nox != null) {
    if (nox > 150) {
      score -= 25;
    } else if (nox > 20) {
      score -= 10;
    }
  }
  final gas = int.tryParse(gasState ?? '');
  if (gas != null) {
    if (gas >= 3) {
      score -= 40;
    } else if (gas == 2) {
      score -= 20;
    } else if (gas == 1) {
      score -= 10;
    }
  }
  return score.clamp(0, 100);
}

(String label, Color color) _scoreQuality(int score) {
  if (score >= 80) return ('Bonne qualité', AppColors.green);
  if (score >= 60) return ('Qualité moyenne', AppColors.amber);
  if (score >= 40) return ('Dégradée', AppColors.red);
  return ('Mauvaise', AppColors.red);
}

// ─── Dashboard ────────────────────────────────────────────────────────────────

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionController>();
    context.watch<SensorController>();

    double? numVal(Sensor s) => double.tryParse(s.value);
    bool boolVal(Sensor s) => s.value == 'true';

    final co2 = numVal(co2Sensor);
    final voc = numVal(vocSensor);
    final nox = numVal(noxSensor);
    final score = _computeAirScore(
      co2: co2,
      voc: voc,
      nox: nox,
      gasState: gasStateSensor.value,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Station'),
        actions: [
          Row(
            children: [
              Icon(Icons.circle,
                  color: conn.isConnected ? AppColors.green : AppColors.amber,
                  size: 8),
              const SizedBox(width: 6),
              Text(conn.statusMessage,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsView())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const _SectionLabel('Qualité de l\'air'),
          const SizedBox(height: 10),
          _AirScoreCard(
            score: score,
            co2: co2,
            voc: voc,
            nox: nox,
            gasState: gasStateSensor.value,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Ambiance'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _TemperatureCard(value: numVal(temperatureSensor))),
            const SizedBox(width: 10),
            Expanded(child: _HumidityCard(value: numVal(humiditySensor))),
          ]),
          const SizedBox(height: 10),
          _LuminosityCard(value: numVal(luminositySensor)),
          const SizedBox(height: 20),
          const _SectionLabel('Capteurs atmosphériques'),
          const SizedBox(height: 10),
          _AtmosphericCard(
            co2: co2,
            pressure: numVal(pressureSensor),
            voc: voc,
            nox: nox,
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Détection'),
          const SizedBox(height: 10),
          _DetectionCard(
            motion:    boolVal(motionSensor),
            sound:     boolVal(soundSensor),
            obstacle:  boolVal(obstacleSensor),
            vibration: boolVal(vibrationSensor),
            gasState:  gasStateSensor.value,
          ),
          const SizedBox(height: 20),
          _LastUpdatedLabel(
              time: context.read<SensorController>().lastUpdated),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 10,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w600,
        ),
      );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.surfaceBorder),
        ),
        child: child,
      );
}

class _CardLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CardLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
        ],
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, color: color)),
      );
}

class _BarIndicator extends StatelessWidget {
  final double fraction;
  final Color? color;
  final Gradient? gradient;

  const _BarIndicator({required this.fraction, this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            width: constraints.maxWidth * fraction.clamp(0, 1),
            decoration: BoxDecoration(
              color: gradient == null ? color : null,
              gradient: gradient,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Air score card ───────────────────────────────────────────────────────────

class _AirScoreCard extends StatelessWidget {
  final int score;
  final double? co2;
  final double? voc;
  final double? nox;
  final String gasState;

  const _AirScoreCard({
    required this.score,
    required this.co2,
    required this.voc,
    required this.nox,
    required this.gasState,
  });

  (String label, Color color) _co2Badge(double? v) {
    if (v == null) return ('–', AppColors.textMuted);
    if (v < 600) return ('CO₂ Bon', AppColors.green);
    if (v < 1000) return ('CO₂ Modéré', AppColors.amber);
    return ('CO₂ Élevé', AppColors.red);
  }

  (String label, Color color) _vocBadge(double? v) {
    if (v == null) return ('–', AppColors.textMuted);
    if (v < 100) return ('VOC Bon', AppColors.green);
    if (v < 150) return ('VOC Modéré', AppColors.amber);
    return ('VOC Élevé', AppColors.red);
  }

  (String label, Color color) _noxBadge(double? v) {
    if (v == null) return ('–', AppColors.textMuted);
    if (v < 20) return ('NOx Bon', AppColors.green);
    if (v < 150) return ('NOx Modéré', AppColors.amber);
    return ('NOx Élevé', AppColors.red);
  }

  (String label, Color color) _gasBadge(String raw) {
    switch (int.tryParse(raw) ?? -1) {
      case 0: return ('Gaz OK', AppColors.green);
      case 1: return ('Gaz Modéré', AppColors.amber);
      case 2: return ('Gaz Élevé', AppColors.red);
      case 3: return ('Danger', AppColors.red);
      default: return ('–', AppColors.textMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (scoreLabel, scoreColor) = _scoreQuality(score);
    final badges = [_co2Badge(co2), _vocBadge(voc), _noxBadge(nox), _gasBadge(gasState)];

    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Text('$score',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                        color: scoreColor)),
                Text('/ 100',
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(scoreLabel,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: badges
                      .where((b) => b.$1 != '–')
                      .map((b) => _Badge(label: b.$1, color: b.$2))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Temperature card ─────────────────────────────────────────────────────────

class _TemperatureCard extends StatelessWidget {
  final double? value;
  const _TemperatureCard({this.value});

  Color _color(double v) {
    if (v < 10) return AppColors.blue;
    if (v < 20) return AppColors.green;
    if (v < 28) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel(icon: Icons.thermostat_outlined, text: 'Température'),
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
                            color: _color(v))),
                    const TextSpan(
                        text: '°C',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 8),
          _BarIndicator(
            fraction: v == null ? 0 : (v / 50),
            color: v == null ? AppColors.surfaceBorder : _color(v),
          ),
        ],
      ),
    );
  }
}

// ─── Humidity card ────────────────────────────────────────────────────────────

class _HumidityCard extends StatelessWidget {
  final double? value;
  const _HumidityCard({this.value});

  @override
  Widget build(BuildContext context) {
    final v = value;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel(icon: Icons.water_drop_outlined, text: 'Humidité'),
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
          _BarIndicator(
            fraction: v == null ? 0 : (v / 100),
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }
}

// ─── Luminosity card ──────────────────────────────────────────────────────────

class _LuminosityCard extends StatelessWidget {
  final double? value;
  const _LuminosityCard({this.value});

  (String label, Color color) _level(double v) {
    if (v < 50)   return ('Sombre', AppColors.textMuted);
    if (v < 300)  return ('Faible', AppColors.textSecondary);
    if (v < 1000) return ('Normal', AppColors.green);
    return ('Lumineux', AppColors.amber);
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    final (label, color) = v == null ? ('–', AppColors.textMuted) : _level(v);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _CardLabel(icon: Icons.wb_sunny_outlined, text: 'Luminosité'),
              const Spacer(),
              _Badge(label: label, color: color),
            ],
          ),
          const SizedBox(height: 8),
          v == null
              ? const Text('–',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 24))
              : RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: v.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const TextSpan(
                        text: ' lux',
                        style: TextStyle(
                            fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 8),
          _BarIndicator(
            fraction: v == null ? 0 : (v / 2000),
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

// ─── Atmospheric card ─────────────────────────────────────────────────────────

class _AtmosphericCard extends StatelessWidget {
  final double? co2;
  final double? pressure;
  final double? voc;
  final double? nox;

  const _AtmosphericCard({this.co2, this.pressure, this.voc, this.nox});

  (String label, Color color) _co2Quality(double v) {
    if (v < 600)  return ('Bon', AppColors.green);
    if (v < 1000) return ('Modéré', AppColors.amber);
    return ('Élevé', AppColors.red);
  }

  (String label, Color color) _pressureQuality(double v) {
    if (v < 1000) return ('Basse', AppColors.blue);
    if (v < 1013) return ('Normale', AppColors.green);
    if (v < 1020) return ('Haute', AppColors.amber);
    return ('Très haute', AppColors.red);
  }

  (String label, Color color) _vocQuality(double v) {
    if (v < 100) return ('Bon', AppColors.green);
    if (v < 150) return ('Modéré', AppColors.amber);
    return ('Élevé', AppColors.red);
  }

  (String label, Color color) _noxQuality(double v) {
    if (v < 20)  return ('Bon', AppColors.green);
    if (v < 150) return ('Modéré', AppColors.amber);
    return ('Élevé', AppColors.red);
  }

  @override
  Widget build(BuildContext context) {
    final (co2Label, co2Color) = co2 == null
        ? ('–', AppColors.textMuted) : _co2Quality(co2!);
    final (pressLabel, pressColor) = pressure == null
        ? ('–', AppColors.textMuted) : _pressureQuality(pressure!);
    final (vocLabel, vocColor) = voc == null
        ? ('–', AppColors.textMuted) : _vocQuality(voc!);
    final (noxLabel, noxColor) = nox == null
        ? ('–', AppColors.textMuted) : _noxQuality(nox!);

    return _Card(
      child: Column(
        children: [
          // CO2 + Pression côte à côte
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _CardLabel(icon: Icons.eco_outlined, text: 'CO₂'),
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
                    _Badge(label: co2Label, color: co2Color),
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
                    const _CardLabel(icon: Icons.compress, text: 'Pression'),
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
                    _Badge(label: pressLabel, color: pressColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _BarIndicator(
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

          const _CardLabel(icon: Icons.air, text: 'VOC / NOx'),
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
              _Badge(label: vocLabel, color: vocColor),
            ],
          ),
          const SizedBox(height: 6),
          _BarIndicator(
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
              _Badge(label: noxLabel, color: noxColor),
            ],
          ),
          const SizedBox(height: 6),
          _BarIndicator(
            fraction: nox == null ? 0 : (nox! / 500),
            color: noxColor,
          ),
        ],
      ),
    );
  }
}

// ─── Detection card ───────────────────────────────────────────────────────────

class _DetectionCard extends StatelessWidget {
  final bool motion;
  final bool sound;
  final bool obstacle;
  final bool vibration;
  final String gasState;

  const _DetectionCard({
    required this.motion,
    required this.sound,
    required this.obstacle,
    required this.vibration,
    required this.gasState,
  });

  (String label, Color color) _gasQuality(String raw) {
    switch (int.tryParse(raw) ?? -1) {
      case 0: return ('Bon', AppColors.green);
      case 1: return ('Modéré', AppColors.amber);
      case 2: return ('Élevé', AppColors.red);
      case 3: return ('Danger', AppColors.red);
      default: return ('–', AppColors.textMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (gasLabel, gasColor) = _gasQuality(gasState);

    return _Card(
      child: Column(
        children: [
          _BoolRow(icon: Icons.directions_walk_outlined, label: 'Mouvement',
              active: motion, onLabel: 'Détecté', offLabel: 'Aucun'),
          _BoolRow(icon: Icons.volume_up_outlined, label: 'Son',
              active: sound, onLabel: 'Détecté', offLabel: 'Calme'),
          _BoolRow(icon: Icons.sensors_outlined, label: 'Obstacle',
              active: obstacle, onLabel: 'Présent', offLabel: 'Aucun'),
          _BoolRow(icon: Icons.vibration, label: 'Vibration',
              active: vibration, onLabel: 'Détectée', offLabel: 'Aucune'),
          _StatusRow(icon: Icons.local_fire_department_outlined,
              label: 'Gaz / Fumée',
              statusLabel: gasLabel, color: gasColor),
        ],
      ),
    );
  }
}

class _BoolRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final String onLabel;
  final String offLabel;

  const _BoolRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.onLabel,
    required this.offLabel,
  });

  @override
  Widget build(BuildContext context) {
    final pillColor = active ? AppColors.green : AppColors.textMuted;
    final pillBg    = active ? AppColors.greenBg : AppColors.surfaceBorder;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pillColor.withValues(alpha: 0.4)),
            ),
            child: Text(active ? onLabel : offLabel,
                style: TextStyle(fontSize: 11, color: pillColor)),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String statusLabel;
  final Color color;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.statusLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Last updated ─────────────────────────────────────────────────────────────

class _LastUpdatedLabel extends StatelessWidget {
  final DateTime? time;
  const _LastUpdatedLabel({this.time});

  @override
  Widget build(BuildContext context) {
    final label = time == null
        ? 'Aucune donnée reçue'
        : 'Mis à jour à ${time!.hour.toString().padLeft(2, '0')}:${time!.minute.toString().padLeft(2, '0')}:${time!.second.toString().padLeft(2, '0')}';

    return Center(
      child: Text(label,
          style:
              const TextStyle(fontSize: 11, color: AppColors.textMuted)),
    );
  }
}