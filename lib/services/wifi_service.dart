import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'connection_service.dart';
import '../models/sensor_model.dart';

class WifiService implements ConnectionService {
  static final _baseUrl =
      dotenv.env['WIFI_AP_BASE_URL'] ?? 'http://192.168.4.1';

  static const _pollInterval = Duration(seconds: 1);
  static const _requestTimeout = Duration(seconds: 3);

  Timer? _pollTimer;
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  @override
  bool isConnected = false;

  @override
  String statusMessage = 'Disconnected';

  @override
  VoidCallback? onConnectionChanged;

  @override
  Future<void> connect() async {
    statusMessage = 'Connecting…';

    // Vérifie que le device est joignable (l'utilisateur doit avoir
    // rejoint le WiFi du HomeStation dans les réglages de son téléphone).
    final reachable = await _fetchMeasurement();

    if (!reachable) {
      isConnected = false;
      statusMessage = 'Device unreachable';
      onConnectionChanged?.call();
      return;
    }

    isConnected = true;
    statusMessage = 'Connected';
    onConnectionChanged?.call();

    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchMeasurement());
  }

  /// Récupère /api/measurement, pousse les données dans le stream si succès.
  /// Retourne true si la requête a abouti.
  Future<bool> _fetchMeasurement() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/api/measurement'))
          .timeout(_requestTimeout);

      if (response.statusCode != 200) {
        _handleFailure('HTTP ${response.statusCode}');
        return false;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      _emit(json);

      if (!isConnected) {
        isConnected = true;
        statusMessage = 'Connected';
        onConnectionChanged?.call();
      }

      return true;
    } catch (e) {
      _handleFailure('$e');
      return false;
    }
  }

  void _handleFailure(String reason) {
    debugPrint('WiFi poll failed: $reason');
    if (isConnected) {
      isConnected = false;
      statusMessage = 'Connection lost';
      onConnectionChanged?.call();
    }
  }

  void _emit(Map<String, dynamic> json) {
    final temperature = (json['temperature'] as num?)?.toDouble();
    final humidity    = (json['humidity']    as num?)?.toDouble();
    final luminosity  = (json['luminosity']  as num?)?.toDouble();
    final pressure    = (json['pressure']    as num?)?.toDouble();
    final co2         = (json['co2']         as num?)?.toInt();
    final vocIndex    = (json['vocIndex']    as num?)?.toInt();
    final noxIndex    = (json['noxIndex']    as num?)?.toInt();
    final gasRaw      = (json['gasRaw']      as num?)?.toInt(); // ← valeur brute, comme demandé

    final motion    = json['motion']    == 1 || json['motion']    == true;
    final sound     = json['sound']     == 1 || json['sound']     == true;
    final obstacle  = json['obstacle']  == 1 || json['obstacle']  == true;
    final vibration = json['vibration'] == 1 || json['vibration'] == true;

    _controller.add({
      temperatureSensor.key: temperature,
      humiditySensor.key:    humidity,
      co2Sensor.key:         co2,
      luminositySensor.key:  luminosity,
      motionSensor.key:      motion,
      soundSensor.key:       sound,
      obstacleSensor.key:    obstacle,
      vibrationSensor.key:   vibration,
      gasRawSensor.key:      gasRaw, 
      pressureSensor.key:    pressure,
      vocSensor.key:         vocIndex,
      noxSensor.key:         noxIndex,
    });
  }

  @override
  Future<void> disconnect() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    isConnected = false;
    statusMessage = 'Disconnected';
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}