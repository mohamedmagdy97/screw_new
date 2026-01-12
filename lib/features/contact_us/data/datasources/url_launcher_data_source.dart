import 'package:url_launcher/url_launcher.dart' as url_launcher;

/// Data source for URL launching operations
abstract class UrlLauncherDataSource {
  /// Launches a URL in an external application
  Future<bool> launchUrl(String url);
}

/// Implementation of URL launcher data source
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

