import 'models/models.dart';


abstract class TOTPDataSource {
  Future<EnrollStartResponse> startEnrollment();

  Future<ConfirmResponse> confirmEnrollment(String code);

  Future<void> verifyChallenge(String code);
}