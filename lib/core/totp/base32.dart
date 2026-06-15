import 'dart:typed_data';


class Base32 {
  static const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

  static Uint8List decode(String input) {
    final cleaned = input.toUpperCase().replaceAll(RegExp(r'[\s=]'), '');
    var bits = 0;
    var value = 0;
    final out = <int>[];
    for (final ch in cleaned.codeUnits) {
      final idx = alphabet.indexOf(String.fromCharCode(ch));
      if (idx == -1) {
        throw const FormatException('Invalid Base32 character in secret');
      }
      value = (value << 5) | idx;
      bits += 5;
      if (bits >= 8) {
        out.add((value >> (bits - 8)) & 0xFF);
        bits -= 8;
      }
    }
    return Uint8List.fromList(out);
  }

  static String encode(Uint8List bytes) {
    var bits = 0;
    var value = 0;
    final out = StringBuffer();
    for (final b in bytes) {
      value = (value << 8) | b;
      bits += 8;
      while (bits >= 5) {
        out.write(alphabet[(value >> (bits - 5)) & 0x1F]);
        bits -= 5;
      }
    }
    if (bits > 0) {
      out.write(alphabet[(value << (5 - bits)) & 0x1F]);
    }
    return out.toString();
  }
}