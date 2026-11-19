import 'package:southsea_cinema/models/user_settings.dart';

class SettingsRepository {
  // one shared copy of the customer's settings for the whole app
  static final SettingsRepository instance = SettingsRepository();

  UserSettings _settings = const UserSettings();

  UserSettings get settings => _settings;

  void save(UserSettings settings) {
    _settings = settings;
  }

  void reset() {
    _settings = const UserSettings();
  }
}
