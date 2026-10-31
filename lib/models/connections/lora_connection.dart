import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'connection_model.dart';
import '../sensor_model.dart';

class LoraConnection extends ConnectionModel {
  static final _apiToken  = dotenv.env['DATACAKE_API_TOKEN']!;
  static final _deviceId  = dotenv.env['DATACAKE_DEVICE_ID']!;
  static const _pollInterval = Duration(seconds: 30);

  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Timer? _pollTimer;

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
    try {
      statusMessage = 'Connecting…';

      // Récupère les dernières valeurs immédiatement
      await _fetchLatest();

      isConnected = true;
      statusMessage = 'Connected';
      onConnectionChanged?.call();

      // Puis poll toutes les 30 secondes
      _pollTimer = Timer.periodic(_pollInterval, (_) async {
        await _fetchLatest();
      });

    } catch (e) {
      isConnected = false;
      statusMessage = 'Error: $e';
      onConnectionChanged?.call();
      debugPrint('Datacake error: $e');
    }
  }

  Future<void> _fetchLatest() async {
    final uri = Uri.parse('https://api.datacake.co/graphql/');

    final query = '''
    {
      allDevices {
        id
        currentMeasurements {
          field {
            fieldName
          }
          value
          modified
        }
      }
    }
    ''';

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Token $_apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode != 200) {
      throw Exception('Datacake HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final devices = data['data']['allDevices'] as List;
    final device = devices.firstWhere((d) => d['id'] == _deviceId);
    final fieldsList = device['currentMeasurements'] as List;

    final result = <String, dynamic>{};
    DateTime? latestMeasurementTime;
    for (final m in fieldsList) {
      final key = (m['field']['fieldName'] as String);
      final value = m['value'];
      final modified = m['modified'];
      if (modified != null) {
        final measurementTime = DateTime.tryParse(modified.toString());
        if (measurementTime != null &&
            (latestMeasurementTime == null ||
                measurementTime.isAfter(latestMeasurementTime))) {
          latestMeasurementTime = measurementTime;
        }
      }

      if (key == SensorKeys.flags) {
        final f = (value is num) ? value.toInt() : int.tryParse('$value') ?? 0;
        result[SensorKeys.motion]    = (f & 0x01) != 0;
        result[SensorKeys.sound]     = (f & 0x02) != 0;
        result[SensorKeys.obstacle]  = (f & 0x04) != 0;
        result[SensorKeys.vibration] = (f & 0x08) != 0;
        continue;
      }

      // Convertit 0/1 en bool pour les champs booléens
      if (key == SensorKeys.motion || key == SensorKeys.sound || key == SensorKeys.obstacle
          || key == SensorKeys.vibration) {
        result[key] = value == 1 || value == true;
      } else {
        result[key] = value;
      }
    }

    if (latestMeasurementTime != null) {
      result[SensorKeys.measurementTimestamp] =
          latestMeasurementTime.toIso8601String();
    }

    if (result.isNotEmpty) {
      _controller.add(result);
    }
  }

  @override
  Future<void> disconnect() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    isConnected = false;
    statusMessage = 'Disconnected';
    onConnectionChanged?.call();
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
