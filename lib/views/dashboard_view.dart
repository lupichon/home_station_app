import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/connection_controller.dart';
import '../controllers/sensor_controller.dart';
import '../models/sensor_model.dart';
import '../theme/app_theme.dart';
import 'settings_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionController>();
    context.watch<SensorController>();

    double? numVal(Sensor s) => double.tryParse(s.value);
    bool boolVal(Sensor s) => s.value == 'true';

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
          const _SectionLabel('Environment'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: _TemperatureGauge(value: numVal(temperatureSensor))),
            const SizedBox(width: 10),
            Expanded(child: _HumidityCard(value: numVal(humiditySensor))),
          ]),
          const SizedBox(height: 10),
          _Co2Card(value: numVal(co2Sensor)),
          const SizedBox(height: 10),
          _LuminosityCard(value: numVal(luminositySensor)),
          const SizedBox(height: 20),
          const _SectionLabel('Detection'),
          const SizedBox(height: 10),
          _DetectionCard(
            motion:   boolVal(motionSensor),
            sound:    boolVal(soundSensor),
            obstacle: boolVal(obstacleSensor),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          letterSpacing: 1.3,
          fontWeight: FontWeight.w600,
        ),
      );
}

// ─── Base card ────────────────────────────────────────────────────────────────

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

// ─── Card label ───────────────────────────────────────────────────────────────

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

// ─── Temperature gauge ────────────────────────────────────────────────────────

class _TemperatureGauge extends StatelessWidget {
  final double? value;
  const _TemperatureGauge({this.value});

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
          const _CardLabel(
              icon: Icons.thermostat_outlined, text: 'Température'),
          const SizedBox(height: 12),
          Center(
            child: SizedBox(
              height: 80,
              width: 110,
              child: CustomPaint(
                painter: _GaugePainter(
                  fraction: v == null ? 0 : (v / 50).clamp(0, 1),
                  color: v == null ? AppColors.surfaceBorder : _color(v),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: v == null
                        ? const Text('–',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 20))
                        : RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: v.toStringAsFixed(1),
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w500,
                                      color: _color(v))),
                              const TextSpan(
                                  text: '°C',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ]),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double fraction;
  final Color color;
  const _GaugePainter({required this.fraction, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.9;
    final radius = size.width * 0.46;
    const startAngle = pi;
    const sweepAngle = pi;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    canvas.drawArc(
      rect, startAngle, sweepAngle, false,
      Paint()
        ..color = AppColors.surfaceBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );

    if (fraction > 0) {
      canvas.drawArc(
        rect, startAngle, sweepAngle * fraction, false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round,
      );
      final angle = startAngle + sweepAngle * fraction;
      canvas.drawCircle(
        Offset(cx + radius * cos(angle), cy + radius * sin(angle)),
        4,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.color != color;
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
          const _CardLabel(
              icon: Icons.water_drop_outlined, text: 'Humidité'),
          const SizedBox(height: 10),
          v == null
              ? const Text('–',
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 22))
              : RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: v.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const TextSpan(
                        text: '%',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 10),
          _BarIndicator(
            fraction: v == null ? 0 : (v / 100).clamp(0, 1),
            color: AppColors.blue,
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
              Text('100%',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── CO2 card ─────────────────────────────────────────────────────────────────

class _Co2Card extends StatelessWidget {
  final double? value;
  const _Co2Card({this.value});

  (String label, Color color) _quality(double v) {
    if (v < 600) return ('Bon', AppColors.green);
    if (v < 1000) return ('Modéré', AppColors.amber);
    return ('Élevé', AppColors.red);
  }

  @override
  Widget build(BuildContext context) {
    final v = value;
    final (label, color) =
        v == null ? ('–', AppColors.textMuted) : _quality(v);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _CardLabel(icon: Icons.eco_outlined, text: 'CO₂'),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child:
                    Text(label, style: TextStyle(fontSize: 11, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          v == null
              ? const Text('–',
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 24))
              : RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: v.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary)),
                    const TextSpan(
                        text: ' ppm',
                        style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 10),
          _BarIndicator(
            fraction: v == null ? 0 : ((v - 400) / 1600).clamp(0, 1),
            color: color,
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('400',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
              Text('1000',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
              Text('2000 ppm',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
            ],
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

  @override
  Widget build(BuildContext context) {
    final v = value;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardLabel(
              icon: Icons.wb_sunny_outlined, text: 'Luminosité'),
          const SizedBox(height: 8),
          v == null
              ? const Text('–',
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 24))
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
                            fontSize: 13,
                            color: AppColors.textSecondary)),
                  ]),
                ),
          const SizedBox(height: 10),
          _BarIndicator(
            fraction: v == null ? 0 : (v / 2000).clamp(0, 1),
            gradient: const LinearGradient(
                colors: [AppColors.amber, Color(0xFFFFE599)]),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
              Text('1000',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
              Text('2000 lux',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Bar indicator ────────────────────────────────────────────────────────────

class _BarIndicator extends StatelessWidget {
  final double fraction;
  final Color? color;
  final Gradient? gradient;

  const _BarIndicator({required this.fraction, this.color, this.gradient});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: 7,
        decoration: BoxDecoration(
          color: AppColors.surfaceBorder,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            width: constraints.maxWidth * fraction,
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

// ─── Detection card ───────────────────────────────────────────────────────────

class _DetectionCard extends StatelessWidget {
  final bool motion;
  final bool sound;
  final bool obstacle;

  const _DetectionCard({
    required this.motion,
    required this.sound,
    required this.obstacle,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          _BoolRow(
            icon: Icons.directions_walk_outlined,
            label: 'Mouvement',
            active: motion,
            onLabel: 'Détecté',
            offLabel: 'Aucun',
          ),
          const SizedBox(height: 10),
          _BoolRow(
            icon: Icons.volume_up_outlined,
            label: 'Son',
            active: sound,
            onLabel: 'Détecté',
            offLabel: 'Calme',
          ),
          const SizedBox(height: 10),
          _BoolRow(
            icon: Icons.sensors_outlined,
            label: 'Obstacle',
            active: obstacle,
            onLabel: 'Présent',
            offLabel: 'Aucun',
          ),
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
    final pillBg = active ? AppColors.greenBg : AppColors.surfaceBorder;

    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: pillBg,
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: pillColor.withValues(alpha: 0.4)),
          ),
          child: Text(active ? onLabel : offLabel,
              style: TextStyle(fontSize: 11, color: pillColor)),
        ),
      ],
    );
  }
}