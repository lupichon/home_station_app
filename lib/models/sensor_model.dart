const emptySensorValue = '--';

class Sensor {
    final String name;
    final String key;
    final String unit;
    String _value;

    Sensor({
        required this.name,
        required this.key,
        this._value = emptySensorValue,
        this.unit = '',
    });

    String get value => _value;

    set value(String? newValue) {
        if (newValue == null || newValue.isEmpty) {
          _value = emptySensorValue;
        } 
        else {
          _value = newValue;
        }
    }
}

final temperatureSensor    = Sensor(name: 'Temperature',   key: 'TEMPERATURE', unit: '°C');
final humiditySensor       = Sensor(name: 'Humidity',      key: 'HUMIDITY',    unit: '%');
final co2Sensor            = Sensor(name: 'CO₂',           key: 'CO2',         unit: 'ppm');
final luminositySensor     = Sensor(name: 'Luminosity',    key: 'LUMINOSITY',  unit: 'lux');
final motionSensor         = Sensor(name: 'Motion',        key: 'MOTION');
final obstacleSensor       = Sensor(name: 'Obstacle',      key: 'OBSTACLE');
final soundSensor          = Sensor(name: 'Sound',         key: 'SOUND');
final vibrationSensor      = Sensor(name: 'Vibration',     key: 'VIBRATION');
final gasStateSensor       = Sensor(name: 'Gas',           key: 'GASSTATE');
final pressureSensor       = Sensor(name: 'Pressure',      key: 'PRESSURE',    unit: 'hPa');
final vocSensor            = Sensor(name: 'VOC',           key: 'VOC');
final noxSensor            = Sensor(name: 'NOx',           key: 'NOX');

final List<Sensor> sensors = [
    temperatureSensor,
    humiditySensor,  
    co2Sensor,
    luminositySensor,
    motionSensor,
    obstacleSensor,
    soundSensor,
    vibrationSensor,
    gasStateSensor,
    pressureSensor,
    vocSensor,
    noxSensor,
];