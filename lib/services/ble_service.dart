import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'connection_service.dart';
import '../models/sensor_model.dart';

/// Service BLE (GATT).
///
/// Variables attendues dans le .env :
///   BLE_DEVICE_NAME   → nom affiché par le périphérique (ex: "HomeStation")
///   BLE_SERVICE_UUID  → UUID du service GATT (ex: "0000181a-0000-1000-8000-00805f9b34fb")
///   BLE_CHARACTERISTIC_UUID → UUID de la caractéristique notify
class BleService implements ConnectionService {
  static final _targetName   = dotenv.env['BLE_DEVICE_NAME'] ?? '';
  static final _serviceUuid  = Guid(dotenv.env['BLE_SERVICE_UUID'] ?? '');
  static final _charUuid     = Guid(dotenv.env['BLE_CHARACTERISTIC_UUID'] ?? '');
  static final _timeSyncUuid = Guid(dotenv.env['BLE_TIME_SYNC_UUID'] ?? '');
  static final _alarmTargetUuid = Guid(dotenv.env['BLE_ALARM_TARGET_UUID'] ?? '');
  static const int _nbFloats    = 4;
  static const int _nbInt16     = 4;
  static const int _nbFlagByte  = 1;

  static const int _expectedLength = _nbFloats * 4 + _nbInt16 * 2 + _nbFlagByte; 

  BluetoothDevice? _device;
  StreamSubscription? _scanSub;
  StreamSubscription? _notifySub;
  StreamSubscription? _connectionStateSub;
  BluetoothCharacteristic? _alarmTargetChar;

  @override
  VoidCallback? onConnectionChanged;

  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  @override
  bool isConnected = false;

  @override
  String statusMessage = 'Disconnected';

  @override
  Future<void> connect() async {
    try {
      statusMessage = 'Scanning…';

      // Scan jusqu'à trouver le device cible
      final completer = Completer<BluetoothDevice>();

      _scanSub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          if (r.device.platformName == _targetName && !completer.isCompleted) {
            completer.complete(r.device);
          }
        }
      });

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));

      _device = await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => throw TimeoutException('Device "$_targetName" not found'),
      );

      await FlutterBluePlus.stopScan();
      _scanSub?.cancel();

      statusMessage = 'Connecting…';
      await _device!.connect(autoConnect: false);

      // Découverte des services
      final services = await _device!.discoverServices();
      final service = services.firstWhere(
        (s) => s.uuid == _serviceUuid,
        orElse: () => throw Exception('Service UUID not found'),
      );

      final char = service.characteristics.firstWhere(
        (c) => c.uuid == _charUuid,
        orElse: () => throw Exception('Characteristic UUID not found'),
      );

      final timeSyncChar = service.characteristics.firstWhere(
        (c) => c.uuid == _timeSyncUuid,
        orElse: () => throw Exception('Time Sync Characteristic UUID not found'),
      );

      _alarmTargetChar = service.characteristics.firstWhere(
        (c) => c.uuid == _alarmTargetUuid,
        orElse: () => throw Exception('Alarm Target Characteristic UUID not found'),
      );

      // Activer les notifications
      await char.setNotifyValue(true);
      _notifySub = char.onValueReceived.listen(_onRawBytes);

      // Écouter la déconnexion
      _connectionStateSub = _device!.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          isConnected = false;
          statusMessage = 'Disconnected';
          onConnectionChanged?.call(); // ← notifie le controller
        }
      });

      isConnected = true;
      statusMessage = 'Connected';
      await _syncTime(timeSyncChar);
    } on TimeoutException catch (e) {
      isConnected = false;
      statusMessage = e.message ?? 'Scan timeout';
    } catch (e) {
      isConnected = false;
      statusMessage = 'Error: $e';
      debugPrint('BLE error: $e');
    }
  }

  void _onRawBytes(List<int> bytes) {
    try {
      if (bytes.length < _expectedLength) {
        debugPrint('BLE frame too short: ${bytes.length} bytes (expected $_expectedLength)');
        return;
      }

      final data = Uint8List.fromList(bytes);
      final bd   = ByteData.sublistView(data);

      // Ordre des floats tel que défini dans serialize()
      final temperature = bd.getFloat32(0,  Endian.little);
      final humidity    = bd.getFloat32(4,  Endian.little);
      final luminosity  = bd.getFloat32(8,  Endian.little);
      final pressure    = bd.getFloat32(12, Endian.little);
      
      final co2         = bd.getUint16(16, Endian.little);
      final voc         = bd.getUint16(18, Endian.little);
      final nox         = bd.getUint16(20, Endian.little);
      final gasRaw      = bd.getUint16(22, Endian.little);

      final flags = data[24];
      final motion    = (flags >> 0) & 0x01 == 1;
      final sound     = (flags >> 1) & 0x01 == 1;
      final obstacle  = (flags >> 2) & 0x01 == 1;
      final vibration = (flags >> 3) & 0x01 == 1;

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
        vocSensor.key:         voc,
        noxSensor.key:         nox,
      });
    } catch (e) {
      debugPrint('BLE parse error: $e');
    }
  }

  Future<void> _syncTime(BluetoothCharacteristic timeSyncChar) async {
    try {
      final epoch = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

      final bytes = Uint8List(4);
      ByteData.sublistView(bytes).setUint32(0, epoch, Endian.little);

      await timeSyncChar.write(bytes, withoutResponse: false);
      debugPrint('Time sync sent: $epoch');
    } catch (e) {
      debugPrint('Time sync failed: $e');
    }
  }

  Future<void> setAlarm(DateTime targetTime) async {
    if (_alarmTargetChar == null) {
      throw Exception('Not connected: alarm characteristic unavailable');
    }

    final epoch = targetTime.toUtc().millisecondsSinceEpoch ~/ 1000;

    final bytes = Uint8List(4);
    ByteData.sublistView(bytes).setUint32(0, epoch, Endian.little);

    await _alarmTargetChar!.write(bytes, withoutResponse: false);
  }

  Future<void> cancelAlarm() async {
    if (_alarmTargetChar == null) {
      throw Exception('Not connected: alarm characteristic unavailable');
    }

    final bytes = Uint8List(4); 
    await _alarmTargetChar!.write(bytes, withoutResponse: false);
  }


  @override
  Future<void> disconnect() async {
    _scanSub?.cancel();
    _notifySub?.cancel();
    _connectionStateSub?.cancel();  // ← ajoute
    await _device?.disconnect();
    _device = null;
    isConnected = false;
    statusMessage = 'Disconnected';
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}