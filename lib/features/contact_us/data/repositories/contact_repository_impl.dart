import 'package:screw_calculator/features/contact_us/data/datasources/url_launcher_data_source.dart';
import 'package:screw_calculator/features/contact_us/domain/repositories/contact_repository.dart';

/// Implementation of contact repository
class ContactRepositoryImpl implements ContactRepository {
  final UrlLauncherDataSource _dataSource;

  ContactRepositoryImpl({
    required UrlLauncherDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<bool> launchUrl(String url) async {
    return await _dataSource.launchUrl(url);
  }
}

