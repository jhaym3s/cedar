part of 'enrollment_bloc.dart';

enum EnrollmentStatus {
  initial,
  loadingSecret, 
  awaitingCode, 
  confirming, 
  confirmInvalid, 
  showingRecoveryCodes, 
  completed,
  error, 
}
 
class EnrollmentState extends Equatable {
  const EnrollmentState({
    this.status = EnrollmentStatus.initial,
    this.otpauthUri,
    this.secret,
    this.recoveryCodes = const [],
    this.errorMessage,
  });
 
  final EnrollmentStatus status;

  final String? otpauthUri;
 
  final String? secret;
 
  final List<String> recoveryCodes;
  final String? errorMessage;
 
  EnrollmentState copyWith({
    EnrollmentStatus? status,
    String? otpauthUri,
    String? secret,
    List<String>? recoveryCodes,
    String? errorMessage,
    bool clearSecret = false,
  }) {
    return EnrollmentState(
      status: status ?? this.status,
      otpauthUri: clearSecret ? null : (otpauthUri ?? this.otpauthUri),
      secret: clearSecret ? null : (secret ?? this.secret),
      recoveryCodes: recoveryCodes ?? this.recoveryCodes,
      errorMessage: errorMessage,
    );
  }
 
  @override
  List<Object?> get props =>
      [status, otpauthUri, secret, recoveryCodes, errorMessage];
 
  
}