const emptySensorValue = '--';

/// Clés des champs reçus des transports (Datacake, BLE, Wi-Fi).
class SensorKeys {
  static const temperature = 'TEMPERATURE';
  static const humidity    = 'HUMIDITY';
  static const co2         = 'CO2';
  static const luminosity  = 'LUMINOSITY';
  static const motion      = 'MOTION';
  static const obstacle    = 'OBSTACLE';
  static const sound       = 'SOUND';
  static const vibration   = 'VIBRATION';
  static const gasRaw      = 'GASSTATE';
  static const pressure    = 'PRESSURE';
  static const voc         = 'VOC';
  static const nox         = 'NOX';
}

class Sensor {
  final String name;
  final String key;
  final String unit;
  String _value;

  Sensor({
    required this.name,
    required this.key,
    this.unit = '',
  }) : _value = emptySensorValue;

  String get value => _value;

  set value(String? newValue) {
    _value = (newValue == null || newValue.isEmpty) ? emptySensorValue : newValue;
  }
}

/// Ensemble des capteurs de la station.
class SensorsModel {
  final temperature = Sensor(name: 'Temp',       key: SensorKeys.temperature, unit: '°C');
  final humidity    = Sensor(name: 'Humidity',   key: SensorKeys.humidity,    unit: '%');
  final co2         = Sensor(name: 'CO₂',        key: SensorKeys.co2,         unit: 'ppm');
  final luminosity  = Sensor(name: 'Luminosity', key: SensorKeys.luminosity,  unit: 'lux');
  final motion      = Sensor(name: 'Motion',     key: SensorKeys.motion);
  final obstacle    = Sensor(name: 'Obstacle',   key: SensorKeys.obstacle);
  final sound       = Sensor(name: 'Sound',      key: SensorKeys.sound);
  final vibration   = Sensor(name: 'Vibration',  key: SensorKeys.vibration);
  final gasRaw      = Sensor(name: 'Gas',        key: SensorKeys.gasRaw);
  final pressure    = Sensor(name: 'Pressure',   key: SensorKeys.pressure,    unit: 'hPa');
  final voc         = Sensor(name: 'VOC',        key: SensorKeys.voc);
  final nox         = Sensor(name: 'NOx',        key: SensorKeys.nox);

  late final List<Sensor> all = [
    temperature, humidity, co2, luminosity, motion, obstacle,
    sound, vibration, gasRaw, pressure, voc, nox,
  ];
}
