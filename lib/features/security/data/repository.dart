import 'models/models.dart';
import 'data_source.dart';

class TOTPRepository {
  TOTPRepository(this._dataSource);

  final TOTPDataSource _dataSource;

  Future<EnrollStartResponse> startEnrollment() =>
      _dataSource.startEnrollment();

  Future<ConfirmResponse> confirmEnrollment(String code) =>
      _dataSource.confirmEnrollment(code);

  Future<void> verifyChallenge(String code) =>
      _dataSource.verifyChallenge(code);
}