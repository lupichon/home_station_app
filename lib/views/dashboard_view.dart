import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/connection_controller.dart';
import '../controllers/sensor_controller.dart';
import '../models/sensor_model.dart';
import '../utils/room_score.dart';  
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

// ─── Dashboard ────────────────────────────────────────────────────────────────

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = context.watch<ConnectionController>();
    context.watch<SensorController>();

    double? numVal(Sensor s) => double.tryParse(s.value);
    bool boolVal(Sensor s) => s.value == 'true';

    final co2           = numVal(co2Sensor);
    final voc           = numVal(vocSensor);
    final nox           = numVal(noxSensor);
    final pressure      = numVal(pressureSensor);
    final luminosity    = numVal(luminositySensor);
    final temperature   = numVal(temperatureSensor);
    final humidity      = numVal(humiditySensor);
    final motion        = boolVal(motionSensor);
    final sound         = boolVal(soundSensor);
    final obstacle      = boolVal(obstacleSensor);
    final vibration     = boolVal(vibrationSensor);
    final gasStateValue = gasStateSensor.value;

    final score = computeRoomScore(co2: co2, voc: voc, nox: nox, gasState: gasStateValue);

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
          const AppSectionLabel('Qualité de l\'air'),
          const SizedBox(height: 10),
          AirScoreCard(
            score: score,
          ),
          const SizedBox(height: 20),
          const AppSectionLabel('Ambiance'),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: TemperatureCard(value: temperature)),
            const SizedBox(width: 10),
            Expanded(child: HumidityCard(value: humidity)),
          ]),
          const SizedBox(height: 10),
          LuminosityCard(value: luminosity),
          const SizedBox(height: 20),
          const AppSectionLabel('Capteurs atmosphériques'),
          const SizedBox(height: 10),
          AtmosphericCard(
            co2: co2,
            pressure: pressure,
            voc: voc,
            nox: nox,
            gasState: gasStateValue 
          ),
          const SizedBox(height: 20),
          const AppSectionLabel('Détection'),
          const SizedBox(height: 10),
          DetectionCard(
            motion: motion,
            sound: sound,
            obstacle: obstacle,
            vibration: vibration,
          ),
          const SizedBox(height: 20),
          AppLastUpdatedLabel(
              time: context.read<SensorController>().lastUpdated),
        ],
      ),
    );
  }
}