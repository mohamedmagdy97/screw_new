import 'package:screw_calculator/features/contact_us/domain/repositories/contact_repository.dart';

/// Use case for launching contact URLs (WhatsApp, LinkedIn, etc.)
class LaunchContactUrlUseCase {
  final ContactRepository _repository;

  LaunchContactUrlUseCase(this._repository);

  /// Executes the use case to launch a contact URL
  /// 
  /// [url] - The URL to launch
  /// Returns true if successful, false otherwise
  Future<bool> call(String url) async {
    return await _repository.launchUrl(url);
  }
}

