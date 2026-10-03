import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/connection_type.dart';
import '../models/preferences_model.dart';
import '../models/connections/connection_model.dart';
import '../models/connections/lora_connection.dart';
import '../models/connections/ble_connection.dart';
import '../models/connections/wifi_connection.dart';
import 'sensor_controller.dart';

class ConnectionController extends ChangeNotifier {
  final SensorController sensorController;
  final PreferencesModel _prefs;

  ConnectionType _activeType = ConnectionType.lora;
  ConnectionType get activeType => _activeType;

  ConnectionModel? _connection;
  StreamSubscription? _dataSub;

  bool get isConnected => _connection?.isConnected ?? false;
  String get statusMessage => _connection?.statusMessage ?? 'Disconnected';

  bool get supportsAlarm => isConnected && (_connection?.supportsAlarm ?? false);

  ConnectionController(this.sensorController, [PreferencesModel? prefs])
      : _prefs = prefs ?? PreferencesModel() {
    _loadPreferenceAndConnect();
  }

  /// Charge la préférence persistée, puis connecte.
  Future<void> _loadPreferenceAndConnect() async {
    _activeType = await _prefs.loadConnectionType();
    await _startConnection(_activeType);
  }

  /// Appelé depuis SettingsView quand l'utilisateur change de transport.
  Future<void> switchTo(ConnectionType type) async {
    if (type == _activeType && isConnected) return;

    // Sauvegarde la préférence
    await _prefs.saveConnectionType(type);

    // Déconnecte l'ancienne connexion (sans reset des données)
    await _teardown();

    _activeType = type;
    notifyListeners();

    await _startConnection(type);
  }

  Future<void> _startConnection(ConnectionType type) async {
    _connection = _buildConnection(type);

    _connection!.onConnectionChanged = () {
      notifyListeners(); 
    };

    _dataSub = _connection!.dataStream.listen((data) {
      sensorController.updateFromJson(data);
      notifyListeners();
    });

    await _connection!.connect();
    notifyListeners();
  }

  Future<void> _teardown() async {
    _dataSub?.cancel();
    _dataSub = null;
    await _connection?.disconnect();
    _connection = null;
  }

  ConnectionModel _buildConnection(ConnectionType type) {
    return switch (type) {
      ConnectionType.lora => LoraConnection(),
      ConnectionType.ble  => BleConnection(),
      ConnectionType.wifi => WifiConnection(),
    };
  }

  @override
  void dispose() {
    _teardown();
    super.dispose();
  }

  Future<void> sendAlarm(DateTime targetTime) async {
    final connection = _connection;
    if (connection == null || !supportsAlarm) {
      throw Exception('Alarm is only supported over BLE for now');
    }
    await connection.setAlarm(targetTime);
  }

  Future<void> sendCancelAlarm() async {
    final connection = _connection;
    if (connection == null || !supportsAlarm) {
      throw Exception('Alarm is only supported over BLE for now');
    }
    await connection.cancelAlarm();
  }
}
