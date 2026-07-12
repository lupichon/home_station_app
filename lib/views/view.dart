import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/mqtt_controller.dart';
import '../controllers/sensor_controller.dart';
import '../models/sensor_model.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final mqtt = context.watch<MqttController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Home Station',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: mqtt.isConnected ? Colors.green : Colors.orange,
                  size: 10,
                ),
                const SizedBox(width: 6),
                Text(
                  mqtt.statusMessage,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sensors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _SensorRow(sensor: sensors[index]);
        },
      ),
    );
  }
}

class _SensorRow extends StatelessWidget {
  final Sensor sensor;
  const _SensorRow({required this.sensor});

  @override
  Widget build(BuildContext context) {
    // watch SensorController pour se reconstruire à chaque mise à jour
    context.watch<SensorController>();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            sensor.name,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
          Text(
            sensor.value == EMPTY_SENSOR_VALUE
                ? sensor.value
                : '${sensor.value} ${sensor.unit}'.trim(),
            style: TextStyle(
              color: sensor.value == EMPTY_SENSOR_VALUE ? Colors.white30 : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}