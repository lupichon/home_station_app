import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/connection_controller.dart';
import '../controllers/sensor_controller.dart';
import '../models/sensor_model.dart';
import 'theme/app_theme.dart';
import 'widgets/section_label.dart';
import 'widgets/last_updated_label.dart';
import 'dashboard/air_score_card.dart';
import 'dashboard/temperature_card.dart';
import 'dashboard/humidity_card.dart';
import 'dashboard/luminosity_card.dart';
import 'dashboard/atmospheric_card.dart';
import 'dashboard/detection_card.dart';
import 'settings_view.dart';
import 'alarm_view.dart';
import 'history_route.dart';
import 'selector_history_menu.dart';

// ─── Dashboard ────────────────────────────────────────────────────────────────

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionController>();
    final sensorCtrl = context.watch<SensorController>();
    final m = sensorCtrl.sensors;

    double? numVal(Sensor s) => sensorCtrl.number(s);
    bool boolVal(Sensor s) => sensorCtrl.flag(s);

    final co2           = numVal(m.co2);
    final voc           = numVal(m.voc);
    final nox           = numVal(m.nox);
    final pressure      = numVal(m.pressure);
    final luminosity    = numVal(m.luminosity);
    final temperature   = numVal(m.temperature);
    final humidity      = numVal(m.humidity);
    final gasRaw        = numVal(m.gasRaw);
    final motion        = boolVal(m.motion);
    final sound         = boolVal(m.sound);
    final obstacle      = boolVal(m.obstacle);
    final vibration     = boolVal(m.vibration);
    final score         = sensorCtrl.roomScore;

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
          IconButton(
            icon: const Icon(Icons.alarm_add_outlined), 
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AlarmView())),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AppSectionLabel('Qualité de l\'air'),
          const SizedBox(height: 10),
          AirScoreCard(
            score: score,
          ),
          const SizedBox(height: 20),
          const AppSectionLabel('Ambiance'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: GestureDetector(
                              onTap: () => openHistory(context, title: m.temperature.name, fieldKey: m.temperature.key, unit: m.temperature.unit),
                              child: TemperatureCard(name: m.temperature.name, value: temperature, unit: m.temperature.unit),
                              ),
                            ),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
                              onTap: () => openHistory(context, title: m.humidity.name, fieldKey: m.humidity.key, unit: m.humidity.unit),
                              child: HumidityCard(name: m.humidity.name, value: humidity, unit: m.humidity.unit),
                              ),
                            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => openHistory(context, title: m.luminosity.name, fieldKey: m.luminosity.key, unit: m.luminosity.unit),
            child: LuminosityCard(name: m.luminosity.name, value: luminosity, unit: m.luminosity.unit),
            ),
          const SizedBox(height: 20),
          const AppSectionLabel('Capteurs atmosphériques'),
          const SizedBox(height: 10),
          GestureDetector(
                onTap: () => openSelectorMenu(context, title: 'Capteurs atmosphériques', fields: [
                  (title: m.co2.name,      fieldKey: m.co2.key,      unit: m.co2.unit),
                  (title: m.pressure.name, fieldKey: m.pressure.key, unit: m.pressure.unit),
                  (title: m.voc.name,      fieldKey: m.voc.key,      unit: m.voc.unit),
                  (title: m.nox.name,      fieldKey: m.nox.key,      unit: m.nox.unit),
                  (title: m.gasRaw.name,   fieldKey: m.gasRaw.key,   unit: m.gasRaw.unit),
                ]),
              child: AtmosphericCard(
              co2Name: m.co2.name,
              co2Value: co2,
              co2Unit: m.co2.unit,
              pressureName: m.pressure.name,
              pressureValue: pressure,
              pressureUnit: m.pressure.unit,
              vocName: m.voc.name,
              vocValue: voc,
              noxName: m.nox.name,
              noxValue: nox,
              gasName: m.gasRaw.name,
              gasRawValue: gasRaw,
            ),
          ),
          const SizedBox(height: 20),
          const AppSectionLabel('Détection'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => openSelectorMenu(context, title: 'Détection', fields: [
              (title: m.motion.name, fieldKey: m.motion.key, unit: m.motion.unit),
              (title: m.sound.name, fieldKey: m.sound.key, unit: m.sound.unit),
              (title: m.obstacle.name, fieldKey: m.obstacle.key, unit: m.obstacle.unit),
              (title: m.vibration.name, fieldKey: m.vibration.key, unit: m.vibration.unit),
            ]),
            child: DetectionCard(
              motionName: m.motion.name,
              motionValue: motion,
              soundName: m.sound.name,
              soundValue: sound,
              obstacleName: m.obstacle.name,
              obstacleValue: obstacle,
              vibrationName: m.vibration.name,
              vibrationValue: vibration,
            ),
          ),
          const SizedBox(height: 20),
          AppLastUpdatedLabel(
              time: context.read<SensorController>().lastUpdated),
        ],
      ),
    );
  }
}