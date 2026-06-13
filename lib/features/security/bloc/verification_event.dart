part of 'verification_bloc.dart';

sealed class VerificationEvent extends Equatable {
  const VerificationEvent();
  @override
  List<Object?> get props => [];
}
 
class VerificationCodeSubmitted extends VerificationEvent {
  const VerificationCodeSubmitted(this.code);
  final String code;
  @override
  List<Object?> get props => [code];
}
 
class VerificationReset extends VerificationEvent {
  const VerificationReset();
}
 