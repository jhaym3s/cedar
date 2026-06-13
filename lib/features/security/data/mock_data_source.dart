import 'dart:math';
import 'dart:typed_data';

import '../../../core/totp/base32.dart';
import '../../../core/totp/totp.dart';
import 'exceptions.dart';
import 'models/models.dart';
import 'data_source.dart';

class MockTOPTDataSource implements TOTPDataSource {
  MockTOPTDataSource({
    Totp? totp,
    DateTime Function()? clock,
    this.networkDelay = const Duration(milliseconds: 20), // Simulate network latency. 
    this.maxAttempts = 5,
    this.lockoutDuration = const Duration(seconds: 30), // Lock out for 30s after max attempts.
    String? fixedSecret, 
  })  : _totp = totp ?? const Totp(),
        _clock = clock ?? DateTime.now,
        _fixedSecret = fixedSecret;

  final Totp _totp;
  final DateTime Function() _clock;
  final Duration networkDelay;
  final int maxAttempts;
  final Duration lockoutDuration;
  final String? _fixedSecret;

  String? _pendingSecret; 
  String? _enrolledSecret; 
  Set<String> _recoveryHashes = {};
  int _lastUsedCounter = -1; 
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  @override
  Future<EnrollStartResponse> startEnrollment() async {
    await _delay();
    final secret = _fixedSecret ?? _generateSecret();
    _pendingSecret = secret;
    final uri = 'otpauth://totp/Cedar:(jhaymesifiok@gmail.com)'
        '?secret=$secret&issuer=Cedar&algorithm=SHA1&digits=6&period=30';
    return EnrollStartResponse(secret: secret, otpauthUri: uri);
  }

  @override
  Future<ConfirmResponse> confirmEnrollment(String code) async {
    await _delay();
    final secret = _pendingSecret;
    if (secret == null) throw const NetworkException('no_pending_enrollment');

    final result = _totp.verify(secret, code, at: _clock());
    if (!result.isValid) throw const InvalidCodeException();

    _enrolledSecret = secret;
    _pendingSecret = null;
    _lastUsedCounter = result.matchedCounter!;

    final codes = _generateRecoveryCodes();
    _recoveryHashes = codes.map(_hash).toSet();
    return ConfirmResponse(recoveryCodes: codes);
  }

  @override
  Future<void> verifyChallenge(String code) async {
    await _delay();
    final secret = _enrolledSecret;
    if (secret == null) throw const NetworkException('not_enrolled');

    final lockedUntil = _lockedUntil;
    if (lockedUntil != null) {
      final now = _clock();
      if (now.isBefore(lockedUntil)) {
        throw LockedOutException(lockedUntil.difference(now));
      }
      _lockedUntil = null;
      _failedAttempts = 0;
    }

    final result =
        _totp.verify(secret, code, at: _clock(), minCounter: _lastUsedCounter);
    if (result.isValid) {
      _lastUsedCounter = result.matchedCounter!; 
      _failedAttempts = 0;
      return;
    }

    _failedAttempts++;
    if (_failedAttempts >= maxAttempts) {
      _lockedUntil = _clock().add(lockoutDuration);
      throw LockedOutException(lockoutDuration);
    }
    throw const InvalidCodeException();
  }

  Future<void> _delay() => Future<void>.delayed(networkDelay);

  String _generateSecret() {
    final rng = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(20, (_) => rng.nextInt(256)), 
    );
    return Base32.encode(bytes);
  }

  List<String> _generateRecoveryCodes({int count = 10}) {
    final rng = Random.secure();
    const alphabet = '0123456789';
    return List.generate(count, (_) {
      final raw =
          List.generate(10, (_) => alphabet[rng.nextInt(alphabet.length)])
              .join();
      return '${raw.substring(0, 5)}-${raw.substring(5)}'; 
    });
  }


  String _hash(String s) => s.hashCode.toRadixString(16);
}