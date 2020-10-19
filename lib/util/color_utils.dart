import 'dart:ui';

import 'package:flutter/material.dart';

extension HexColor on Color {
  static Color DEFAULT_COLOR = Colors.white;

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  static Color fromCss(String cssColorString) {
    if (cssColorString.startsWith("#")) {
      return fromHex(cssColorString);
    } else if (cssColorString.startsWith("rgb")) {
      return fromRgba(cssColorString);
    }
    return DEFAULT_COLOR;
  }

  static Color fromRgba(String rgbaString) {
    int startIndex = 0;
    if (rgbaString.startsWith("rgba")) {
      startIndex = 5;
    } else if (rgbaString.startsWith("rgb")) {
      startIndex = 4;
    }

    int length = rgbaString.length;

    rgbaString = rgbaString.substring(startIndex, length - 2);
    List<String> parts = rgbaString.split(",");

    if (parts.length == 3) {
      return Color.fromARGB(
          255, int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } else if (parts.length == 4) {
      double last = double.parse(parts[3]);
      if (last <= 1 && last >= 0) {
        return Color.fromRGBO(int.parse(parts[0]), int.parse(parts[1]),
            int.parse(parts[2]), last);
      } else {
        return Color.fromARGB(int.parse(parts[3]), int.parse(parts[0]),
            int.parse(parts[1]), int.parse(parts[2]));
      }
    } else {
      return DEFAULT_COLOR;
    }
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}