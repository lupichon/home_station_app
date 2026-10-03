import 'package:shared_preferences/shared_preferences.dart';
import 'connection_type.dart';

class PreferencesModel {
  static const _connectionKey = 'connection_type';

  Future<ConnectionType> loadConnectionType() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_connectionKey);
    return ConnectionType.values.firstWhere(
      (t) => t.key == key,
      orElse: () => ConnectionType.lora,
    );
  }

  Future<void> saveConnectionType(ConnectionType type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_connectionKey, type.key);
  }
}
