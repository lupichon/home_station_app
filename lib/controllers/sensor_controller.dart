import 'package:flutter/foundation.dart';
import '../models/sensor_model.dart';

class SensorController extends ChangeNotifier {
  void updateFromJson(Map<String, dynamic> json) {
    for (final sensor in sensors) {
      sensor.value = json[sensor.key]?.toString();
    }
    notifyListeners();
  }
}