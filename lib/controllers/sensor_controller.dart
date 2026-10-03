import 'package:flutter/foundation.dart';
import '../models/sensor_model.dart';
import '../utils/room_score.dart';

class SensorController extends ChangeNotifier {
  final SensorsModel sensors = SensorsModel();
  DateTime? lastUpdated;

  void updateFromJson(Map<String, dynamic> json) {
    for (final sensor in sensors.all) {
      sensor.value = json[sensor.key]?.toString();
    }
    lastUpdated = DateTime.now();
    notifyListeners();
  }

  double? number(Sensor s) => double.tryParse(s.value);

  bool flag(Sensor s) => s.value == 'true';

  double get roomScore => computeRoomScore(
        temperature: number(sensors.temperature),
        humidity: number(sensors.humidity),
        co2: number(sensors.co2),
        voc: number(sensors.voc),
        nox: number(sensors.nox),
        gasRaw: number(sensors.gasRaw),
      );
}
