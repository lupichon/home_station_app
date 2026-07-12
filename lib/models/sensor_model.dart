const EMPTY_SENSOR_VALUE = '--';

class Sensor {
    final String name;
    final String key;
    final String unit;
    String _value;

    Sensor({
        required this.name,
        required this.key,
        this._value = EMPTY_SENSOR_VALUE,
        this.unit = '',
    });

    String get value => _value;

    set value(String? newValue) {
        if (newValue == null || newValue.isEmpty) {
          _value = EMPTY_SENSOR_VALUE;
        } 
        else {
          _value = newValue;
        }
    }
}

final temperatureSensor    = Sensor(name: 'Temperature',   key: 'temperature', unit: '°C');
final humiditySensor       = Sensor(name: 'Humidity',      key: 'humidity',    unit: '%');
final pressureSensor       = Sensor(name: 'Pressure',      key: 'pressure',    unit: 'hPa');
final co2Sensor            = Sensor(name: 'CO₂',           key: 'co2',         unit: 'ppm');
final covSensor            = Sensor(name: 'COV',           key: 'cov',         unit: 'IAQ');
final luminositySensor     = Sensor(name: 'Luminosity',    key: 'luminosity',  unit: 'lux');
final soundLevelSensor     = Sensor(name: 'Sound level',   key: 'sound_level', unit: 'dB');
final motionSensor         = Sensor(name: 'Motion',        key: 'motion');
final waterLeakSensor      = Sensor(name: 'Water leak',    key: 'water_leak');

final List<Sensor> sensors = [
    temperatureSensor,
    humiditySensor,  
    pressureSensor,
    co2Sensor,
    covSensor,
    luminositySensor,
    soundLevelSensor,
    motionSensor,
    waterLeakSensor,
];