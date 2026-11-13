import 'package:url_launcher/url_launcher.dart' as url_launcher;

abstract class UrlLauncherDataSource {
  Future<bool> launchUrl(String url);
}

class UrlLauncherDataSourceImpl implements UrlLauncherDataSource {
  @override
  Future<bool> launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await url_launcher.canLaunchUrl(uri)) {
        return false;
      }
      final bool launched = await url_launcher.launchUrl(
        uri,
        mode: url_launcher.LaunchMode.externalApplication,
      );
      return launched;
    } catch (e) {
      return false;
    }
  }
}
