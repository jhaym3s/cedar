part of 'enrollment_bloc.dart';

sealed class EnrollmentEvent extends Equatable {
  const EnrollmentEvent();
  @override
  List<Object?> get props => [];
}
 
class EnrollmentStarted extends EnrollmentEvent {
  const EnrollmentStarted();
}
 
class EnrollmentCodeSubmitted extends EnrollmentEvent {
  const EnrollmentCodeSubmitted(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}
 
class RecoveryCodesAcknowledged extends EnrollmentEvent {
  const RecoveryCodesAcknowledged();
}
 