// ignore_for_file: deprecated_member_use

import 'dart:ui';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final cleanHex = hexString.replaceFirst('#', '');
    final buffer = StringBuffer();

    // Если длина 6 символов (RGB), добавляем полную прозрачность (FF)
    if (cleanHex.length == 6) {
      buffer.write('ff');
    }
    buffer.write(cleanHex);

    final result = Color(int.parse(buffer.toString(), radix: 16));

    return result;
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
