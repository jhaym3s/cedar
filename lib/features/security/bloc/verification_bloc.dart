import 'package:bloc/bloc.dart';
import 'package:cedar/features/security/data/exceptions.dart';
import 'package:cedar/features/security/data/repository.dart';
import 'package:equatable/equatable.dart';

part 'verification_event.dart';
part 'verification_state.dart';



class VerificationBloc extends Bloc<VerificationEvent, VerificationState> {
  VerificationBloc(this._repository, {this.maxAttempts = 5})
      : super(VerificationState(attemptsRemaining: maxAttempts)) {
    on<VerificationCodeSubmitted>(_onSubmitted);
    on<VerificationReset>(_onReset);
  }

  final TOTPRepository _repository;
  final int maxAttempts;

  Future<void> _onSubmitted(
    VerificationCodeSubmitted event,
    Emitter<VerificationState> emit,
  ) async {
    if (state.status == VerificationStatus.lockedOut) return;

    emit(state.copyWith(status: VerificationStatus.verifying));
    try {
      await _repository.verifyChallenge(event.code);
      emit(state.copyWith(
        status: VerificationStatus.success,
        attemptsRemaining: maxAttempts,
      ));
    } on InvalidCodeException {
      final remaining =
          (state.attemptsRemaining - 1).clamp(0, maxAttempts);
      emit(state.copyWith(
        status: VerificationStatus.invalid,
        attemptsRemaining: remaining,
      ));
    } on LockedOutException catch (e) {
      emit(state.copyWith(
        status: VerificationStatus.lockedOut,
        attemptsRemaining: 0,
        retryAfter: e.retryAfter,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: VerificationStatus.error,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  void _onReset(VerificationReset event, Emitter<VerificationState> emit) {
    emit(VerificationState(attemptsRemaining: maxAttempts));
  }
}