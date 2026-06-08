import 'package:bloc/bloc.dart';
import 'package:cedar/features/security/data/exceptions.dart';
import 'package:cedar/features/security/data/repository.dart';
import 'package:equatable/equatable.dart';

part 'enrollment_event.dart';
part 'enrollment_state.dart';

class EnrollmentBloc extends Bloc<EnrollmentEvent, EnrollmentState> {
  EnrollmentBloc(this._repository) : super(const EnrollmentState()) {
    on<EnrollmentStarted>(_onStarted);
    on<EnrollmentCodeSubmitted>(_onCodeSubmitted);
    on<RecoveryCodesAcknowledged>(_onReceived);
  }
 
  final TOTPRepository _repository;
 
  Future<void> _onStarted(
    EnrollmentStarted event,
    Emitter<EnrollmentState> emit,
  ) async {
    emit(state.copyWith(status: EnrollmentStatus.loadingSecret));
    try {
      final res = await _repository.startEnrollment();
      emit(state.copyWith(
        status: EnrollmentStatus.awaitingCode,
        otpauthUri: res.otpauthUri,
        secret: res.secret,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: EnrollmentStatus.error,
        errorMessage: 'Could not start enrollment. Please try again.',
      ));
    }
  }
 
  Future<void> _onCodeSubmitted(
    EnrollmentCodeSubmitted event,
    Emitter<EnrollmentState> emit,
  ) async {
    emit(state.copyWith(status: EnrollmentStatus.confirming));
    try {
      final res = await _repository.confirmEnrollment(event.code);
      emit(state.copyWith(
        status: EnrollmentStatus.showingRecoveryCodes,
        recoveryCodes: res.recoveryCodes,
        clearSecret: true,
      ));
    } on InvalidCodeException {
      emit(state.copyWith(status: EnrollmentStatus.confirmInvalid));
    } catch (_) {
      emit(state.copyWith(
        status: EnrollmentStatus.error,
        errorMessage: 'Verification failed. Please try again.',
      ));
    }
  }
 
  void _onReceived(
    RecoveryCodesAcknowledged event,
    Emitter<EnrollmentState> emit,
  ) {
    emit(const EnrollmentState(status: EnrollmentStatus.completed));
  }
}