import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'connection_service.dart';
import '../models/sensor_model.dart';

class LoraService implements ConnectionService {
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

    debugPrint('Datacake response: ${response.body}', wrapWidth: 10000);

    if (response.statusCode != 200) {
      throw Exception('Datacake HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final devices = data['data']['allDevices'] as List;
    final device = devices.firstWhere((d) => d['id'] == _deviceId);
    final fieldsList = device['currentMeasurements'] as List;

    final result = <String, dynamic>{};
    for (final m in fieldsList) {
      final key = (m['field']['fieldName'] as String);
      final value = m['value'];
      // Convertit 0/1 en bool pour les champs booléens
      if (key == motionSensor.key || key == soundSensor.key || key == obstacleSensor.key
          || key == vibrationSensor.key) {
        result[key] = value == 1 || value == true;
      }
      else if (key == gasStateSensor.key) {
    	result[key] = (value as num).toInt(); // 2.0 → 2
      } else {
        result[key] = value;
      }
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
