import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'sensor_controller.dart';

class MqttController extends ChangeNotifier {
  static final _appId    = dotenv.env['TTN_APP_ID']!;
  static final _apiKey   = dotenv.env['TTN_API_KEY']!;
  static final _deviceId = dotenv.env['TTN_DEVICE_ID']!;
  static final _host     = dotenv.env['TTN_HOST']!;

  late MqttServerClient _client;
  bool isConnected = false;
  String statusMessage = 'Disconnected';

  final SensorController sensorController;

  MqttController(this.sensorController) {
    _connect();
  }

  Future<void> _connect() async {
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
      notifyListeners();

      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        isConnected = true;
        statusMessage = 'Connected';
        notifyListeners();

        final topic = 'v3/$_appId@ttn/devices/$_deviceId/up';
        _client.subscribe(topic, MqttQos.atLeastOnce);

        _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
          final msg = messages[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(msg.payload.message);
          _onMessageReceived(payload);
        });
      } 
      else {
        statusMessage = 'Failed: ${_client.connectionStatus?.returnCode}';
        notifyListeners();
      }
    } catch (e) {
      statusMessage = 'Error: $e';
      debugPrint('MQTT error: $e');
      notifyListeners();
    }
  }

  void _onMessageReceived(String payload) {
    try {
      final json = jsonDecode(payload);
      final decoded = json['uplink_message']?['decoded_payload'];
      if (decoded != null) {
        sensorController.updateFromJson(decoded);
      }
    } catch (e) {
      debugPrint('MQTT parsing error: $e');
    }
  }

  @override
  void dispose() {
    _client.disconnect();
    super.dispose();
  }
}