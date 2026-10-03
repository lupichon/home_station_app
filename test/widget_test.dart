import 'package:flutter_test/flutter_test.dart';
import 'package:home_station_app/controllers/sensor_controller.dart';

void main() {
  test('SensorController parse les valeurs et calcule le score', () {
    final c = SensorController();
    c.updateFromJson({'TEMPERATURE': 22, 'HUMIDITY': 45, 'MOTION': true});

    expect(c.number(c.sensors.temperature), 22);
    expect(c.flag(c.sensors.motion), isTrue);
    expect(c.roomScore, inInclusiveRange(0, 100));
    expect(c.lastUpdated, isNotNull);
  });
}
