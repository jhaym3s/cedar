part of 'verification_bloc.dart';

enum VerificationStatus {
  idle,
  verifying,
  success,
  invalid, 
  lockedOut, 
  error, 
}
 
class VerificationState extends Equatable {
  const VerificationState({
    this.status = VerificationStatus.idle,
    this.attemptsRemaining = 5,
    this.retryAfter,
    this.errorMessage,
  });
 
  final VerificationStatus status;
  final int attemptsRemaining;
  final Duration? retryAfter;
  final String? errorMessage;
 
  VerificationState copyWith({
    VerificationStatus? status,
    int? attemptsRemaining,
    Duration? retryAfter,
    String? errorMessage,
  }) {
    return VerificationState(
      status: status ?? this.status,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      retryAfter: retryAfter,
      errorMessage: errorMessage,
    );
  }
 
  @override
  List<Object?> get props =>
      [status, attemptsRemaining, retryAfter, errorMessage];
}