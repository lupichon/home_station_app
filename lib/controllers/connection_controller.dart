import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/connection_type.dart';
import '../services/connection_service.dart';
import '../services/mqtt_service.dart';
import '../services/ble_service.dart';
import '../services/wifi_service.dart';
import 'sensor_controller.dart';

class ConnectionController extends ChangeNotifier {
  final SensorController sensorController;

  ConnectionType _activeType = ConnectionType.lora;
  ConnectionType get activeType => _activeType;

  ConnectionService? _service;
  StreamSubscription? _dataSub;

  bool get isConnected => _service?.isConnected ?? false;
  String get statusMessage => _service?.statusMessage ?? 'Disconnected';

  ConnectionController(this.sensorController) {
    _loadPreferenceAndConnect();
  }

  /// Charge la préférence persistée, puis connecte.
  Future<void> _loadPreferenceAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('connection_type');
    if (key != null) {
      _activeType = ConnectionType.values.firstWhere(
        (t) => t.key == key,
        orElse: () => ConnectionType.lora,
      );
    }
    await _startService(_activeType);
  }

  /// Appelé depuis SettingsView quand l'utilisateur change de transport.
  Future<void> switchTo(ConnectionType type) async {
    if (type == _activeType && isConnected) return;

    // Sauvegarde la préférence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('connection_type', type.key);

    // Déconnecte l'ancien service (sans reset des données)
    await _teardown();

    _activeType = type;
    notifyListeners();

    await _startService(type);
  }

  Future<void> _startService(ConnectionType type) async {
    _service = _buildService(type);
    _dataSub = _service!.dataStream.listen((data) {
      sensorController.updateFromJson(data);
      notifyListeners(); // pour rafraîchir statusMessage / isConnected
    });

    await _service!.connect();
    notifyListeners();
  }

  Future<void> _teardown() async {
    _dataSub?.cancel();
    _dataSub = null;
    await _service?.disconnect();
    _service = null;
  }

  ConnectionService _buildService(ConnectionType type) {
    return switch (type) {
      ConnectionType.lora => MqttService(),
      ConnectionType.ble  => BleService(),
      ConnectionType.wifi => WifiService(),
    };
  }

  @override
  void dispose() {
    _teardown();
    super.dispose();
  }
}