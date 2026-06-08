import 'dart:typed_data';
import 'package:crypto/crypto.dart';

import 'base32.dart';


class TotpResult {
  const TotpResult.valid(this.matchedCounter)
      : isValid = true;
  const TotpResult.invalid()
      : isValid = false,
        matchedCounter = null;

  final bool isValid;
  final int? matchedCounter;
}

class Totp {
  const Totp({
    this.digits = 6,
    this.period = 30,
    this.window = 1, 
  });

  final int digits;
  final int period;
  final int window;

  int _counterAt(int unixSeconds) => unixSeconds ~/ period;


  String generateForCounter(String base32Secret, int counter) {
    final key = Base32.decode(base32Secret);
    final msg = Uint8List(8);
    var c = counter;
    for (var i = 7; i >= 0; i--) {
      msg[i] = c & 0xFF;
      c >>= 8;
    }
    final digest = Hmac(sha1, key).convert(msg).bytes;
    final offset = digest[digest.length - 1] & 0x0F;
    final binary = ((digest[offset] & 0x7F) << 24) |
        ((digest[offset + 1] & 0xFF) << 16) |
        ((digest[offset + 2] & 0xFF) << 8) |
        (digest[offset + 3] & 0xFF);
    final mod = _pow10(digits);
    return (binary % mod).toString().padLeft(digits, '0');
  }

  String generate(String base32Secret, {DateTime? at}) {
    final now = (at ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    return generateForCounter(base32Secret, _counterAt(now));
  }

  
  TotpResult verify(
    String base32Secret,
    String code, {
    DateTime? at,
    int minCounter = -1,
  }) {
    final trimmed = code.trim();
    if (trimmed.length != digits || int.tryParse(trimmed) == null) {
      return const TotpResult.invalid();
    }
    final now = (at ?? DateTime.now()).millisecondsSinceEpoch ~/ 1000;
    final center = _counterAt(now);
    for (var i = -window; i <= window; i++) {
      final counter = center + i;
      if (counter <= minCounter) continue; 
      final candidate = generateForCounter(base32Secret, counter);
      if (_constantTimeEquals(candidate, trimmed)) {
        return TotpResult.valid(counter);
      }
    }
    return const TotpResult.invalid();
  }

  static int _pow10(int n) {
    var r = 1;
    for (var i = 0; i < n; i++) {
      r *= 10;
    }
    return r;
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}