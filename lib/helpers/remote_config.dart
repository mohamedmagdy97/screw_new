import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfig {
  final remoteConfig = FirebaseRemoteConfig.instance;

  void getConfig() async {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(milliseconds: 500),
      ),
    );

    await remoteConfig.setDefaults({
      'chat_enabled': false,
      'blocked_users': '',
      'allowed_users': '',
    });

    await remoteConfig.fetchAndActivate();
  }

  bool canAccessChat({required String phone, required String name}) {
    final chatEnabled = remoteConfig.getBool('chat_enabled');

    final blockedUsers = remoteConfig.getString('blocked_users').toLowerCase();
    final allowedUsers = remoteConfig.getString('allowed_users').toLowerCase();

    // print('mmmmmmmmmmmmmmmm==$chatEnabled ==$blockedUsers ====$allowedUsers');
    final identifier = phone.toLowerCase();
    final nameLower = name.toLowerCase();

    if (allowedUsers.contains(identifier) || allowedUsers.contains(nameLower)) {
      return true;
    }

    if (!chatEnabled) return false;

    if (blockedUsers.contains(identifier) || blockedUsers.contains(nameLower)) {
      return false;
    }

    return true;
  }
}
