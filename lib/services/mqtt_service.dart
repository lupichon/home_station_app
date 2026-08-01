import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'connection_service.dart';

class MqttService implements ConnectionService {
  static final _appId    = dotenv.env['TTN_APP_ID']!;
  static final _apiKey   = dotenv.env['TTN_API_KEY']!;
  static final _deviceId = dotenv.env['TTN_DEVICE_ID']!;
  static final _host     = dotenv.env['TTN_HOST']!;

  late MqttServerClient _client;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  @override
  bool isConnected = false;

  @override
  String statusMessage = 'Disconnected';

  @override
  Future<void> connect() async {
    final clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';

    _client = MqttServerClient(_host, clientId);
    _client.port = 1883;
    _client.keepAlivePeriod = 60;
    _client.logging(on: false);

    _client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs('$_appId@ttn', _apiKey)
        .startClean();

    try {
      statusMessage = 'Connecting…';
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        isConnected = true;
        statusMessage = 'Connected';

        final topic = 'v3/$_appId@ttn/devices/$_deviceId/up';
        _client.subscribe(topic, MqttQos.atLeastOnce);

        _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
          final msg = messages[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
          _onRawMessage(payload);
        });
      } else {
        isConnected = false;
        statusMessage = 'Failed: ${_client.connectionStatus?.returnCode}';
      }
    } catch (e) {
      isConnected = false;
      statusMessage = 'Error: $e';
      debugPrint('MQTT error: $e');
    }
  }

  void _onRawMessage(String payload) {
    try {
      final json = jsonDecode(payload);
      final decoded = json['uplink_message']?['decoded_payload'];
      if (decoded != null) {
        _controller.add(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint('MQTT parse error: $e');
    }
  }

  @override
  Future<void> disconnect() async {
    _client.disconnect();
    isConnected = false;
    statusMessage = 'Disconnected';
  }

  void dispose() {
    _controller.close();
    _client.disconnect();
  }
}