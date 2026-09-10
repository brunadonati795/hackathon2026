import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AppStorage {
  Future<String?> read();

  Future<void> write(String value);
}

class SharedPreferencesAppStorage implements AppStorage {
  SharedPreferencesAppStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _stateKey = 'cuidarmais.app_state.v1';
  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read() => _preferences.getString(_stateKey);

  @override
  Future<void> write(String value) => _preferences.setString(_stateKey, value);
}
