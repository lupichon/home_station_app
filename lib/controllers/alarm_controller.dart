import 'package:flutter/foundation.dart';
import 'connection_controller.dart';

class AlarmController extends ChangeNotifier {
  final ConnectionController _connection;

  DateTime? _target;
  DateTime? get alarmTarget => _target;
  bool get isAlarmArmed => _target != null;
  bool get supportsAlarm => _connection.supportsAlarm;

  AlarmController(this._connection) {
    _connection.addListener(notifyListeners);
  }

  Future<void> setAlarm(DateTime targetTime) async {
    if (targetTime.isBefore(DateTime.now())) {
      throw Exception("L'heure choisie est déjà passée");
    }
    await _connection.sendAlarm(targetTime);
    _target = targetTime;
    notifyListeners();
  }

  Future<void> cancelAlarm() async {
    await _connection.sendCancelAlarm();
    _target = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _connection.removeListener(notifyListeners);
    super.dispose();
  }
}
