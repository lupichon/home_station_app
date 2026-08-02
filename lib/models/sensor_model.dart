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

final temperatureSensor    = Sensor(name: 'Temperature',   key: 'temperature', unit: '°C');
final humiditySensor       = Sensor(name: 'Humidity',      key: 'humidity',    unit: '%');
final co2Sensor            = Sensor(name: 'CO₂',           key: 'co2',         unit: 'ppm');
final luminositySensor     = Sensor(name: 'Luminosity',    key: 'luminosity',  unit: 'lux');
final motionSensor         = Sensor(name: 'Motion',        key: 'motion');
final obstacleSensor       = Sensor(name: 'Obstacle',      key: 'obstacle');
final soundSensor          = Sensor(name: 'Sound',         key: 'sound');
final vibrationSensor      = Sensor(name: 'Vibration',     key: 'vibration');

final List<Sensor> sensors = [
    temperatureSensor,
    humiditySensor,  
    co2Sensor,
    luminositySensor,
    motionSensor,
    obstacleSensor,
    soundSensor,
    vibrationSensor,
];