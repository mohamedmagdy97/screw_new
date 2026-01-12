/// Repository interface for contact-related operations
abstract class ContactRepository {
  /// Launches a URL in an external application
  /// Returns true if the URL was launched successfully, false otherwise
  Future<bool> launchUrl(String url);
}

