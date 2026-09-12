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
import 'alarm_view.dart';
import 'history_route.dart';
import 'selector_history_menu.dart';

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

    final score = computeRoomScore(temperature: temperature, humidity: humidity, co2: co2, voc: voc, nox: nox, gasState: gasStateValue);

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
                              onTap: () => openHistory(context, title: temperatureSensor.name, fieldKey: temperatureSensor.key, unit: temperatureSensor.unit),
                              child: TemperatureCard(name: temperatureSensor.name, value: temperature, unit: temperatureSensor.unit),
                              ),
                            ),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
                              onTap: () => openHistory(context, title: humiditySensor.name, fieldKey: humiditySensor.key, unit: humiditySensor.unit),
                              child: HumidityCard(name: humiditySensor.name, value: humidity, unit: humiditySensor.unit),
                              ),
                            ),
          ]),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => openHistory(context, title: luminositySensor.name, fieldKey: luminositySensor.key, unit: luminositySensor.unit),
            child: LuminosityCard(name: luminositySensor.name, value: luminosity, unit: luminositySensor.unit),
            ),
          const SizedBox(height: 20),
          const AppSectionLabel('Capteurs atmosphériques'),
          const SizedBox(height: 10),
          GestureDetector(
                onTap: () => openSelectorMenu(context, title: 'Capteurs atmosphériques', fields: [
                  (title: co2Sensor.name,      fieldKey: co2Sensor.key,      unit: co2Sensor.unit),
                  (title: pressureSensor.name, fieldKey: pressureSensor.key, unit: pressureSensor.unit),
                  (title: vocSensor.name,      fieldKey: vocSensor.key,      unit: vocSensor.unit),
                  (title: noxSensor.name,      fieldKey: noxSensor.key,      unit: noxSensor.unit),
                  (title: gasStateSensor.name, fieldKey: gasStateSensor.key, unit: gasStateSensor.unit),
                ]),
              child: AtmosphericCard(
              co2Name: co2Sensor.name,
              co2Value: co2,
              co2Unit: co2Sensor.unit,
              pressureName: pressureSensor.name,
              pressureValue: pressure,
              pressureUnit: pressureSensor.unit,
              vocName: vocSensor.name,
              vocValue: voc,
              noxName: noxSensor.name,
              noxValue: nox,
              gasName: gasStateSensor.name,
              gasStateValue: gasStateValue,
            ),
          ),
          const SizedBox(height: 20),
          const AppSectionLabel('Détection'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => openSelectorMenu(context, title: 'Détection', fields: [
              (title: motionSensor.name, fieldKey: motionSensor.key, unit: motionSensor.unit),
              (title: soundSensor.name, fieldKey: soundSensor.key, unit: soundSensor.unit),
              (title: obstacleSensor.name, fieldKey: obstacleSensor.key, unit: obstacleSensor.unit),
              (title: vibrationSensor.name, fieldKey: vibrationSensor.key, unit: vibrationSensor.unit),
            ]),
            child: DetectionCard(
              motionName: motionSensor.name,
              motionValue: motion,
              soundName: soundSensor.name,
              soundValue: sound,
              obstacleName: obstacleSensor.name,
              obstacleValue: obstacle,
              vibrationName: vibrationSensor.name,
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