/// A pure Dart implementation of the Python `jaconv` library for Japanese character conversion.
library jaconv_dart;

export 'src/jaconv_extensions.dart';

// We also export top-level functions for convenience (to be compatible with the python style optionally, or just for ease of use)
import 'src/jaconv_extensions.dart';

/// Converts Hiragana to Full-width (Zenkaku) Katakana.
String toKatakana(String text, {String ignore = ''}) =>
    text.toKatakana(ignore: ignore);

/// Converts Hiragana to Half-width (Hankaku) Katakana.
String toHankakuKatakana(String text, {String ignore = ''}) =>
    text.toHankakuKatakana(ignore: ignore);

/// Converts Full-width Katakana to Hiragana.
String toHiragana(String text, {String ignore = ''}) =>
    text.toHiragana(ignore: ignore);

/// Converts small Hiragana or Katakana to normal size.
String toNormalKana(String text, {String ignore = ''}) =>
    text.toNormalKana(ignore: ignore);

/// Converts Half-width (Hankaku) characters to Full-width (Zenkaku).
String toZenkaku(
  String text, {
  bool kana = true,
  bool ascii = false,
  bool digit = false,
  String ignore = '',
}) => text.toZenkaku(kana: kana, ascii: ascii, digit: digit, ignore: ignore);

/// Converts Full-width (Zenkaku) characters to Half-width (Hankaku).
String toHankaku(
  String text, {
  bool kana = true,
  bool ascii = false,
  bool digit = false,
  String ignore = '',
}) => text.toHankaku(kana: kana, ascii: ascii, digit: digit, ignore: ignore);

/// Convert Hiragana/Katakana to Roman-input-style alphabet
String toAlphabet(String text) => text.toAlphabet();

/// Normalizes characters.
String normalizeKana(String text) => text.normalizeKana();
