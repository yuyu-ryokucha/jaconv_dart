import 'conv_table.dart';

/// Extension methods on [String] for Japanese character conversions.
extension JaconvStringExtension on String {
  String _translate(String ignore, Map<int, String> convMap) {
    if (isEmpty) return this;
    final ignoreCodePoints = ignore.runes.toSet();
    final buffer = StringBuffer();
    for (final cp in runes) {
      if (ignoreCodePoints.contains(cp)) {
        buffer.writeCharCode(cp);
      } else {
        final replacement = convMap[cp];
        if (replacement != null) {
          buffer.write(replacement);
        } else {
          buffer.writeCharCode(cp);
        }
      }
    }
    return buffer.toString();
  }

  /// Converts Hiragana to Full-width (Zenkaku) Katakana.
  String toKatakana({String ignore = ''}) {
    return _translate(ignore, h2kTable);
  }

  /// Converts Hiragana to Half-width (Hankaku) Katakana.
  String toHankakuKatakana({String ignore = ''}) {
    return _translate(ignore, h2hkTable);
  }

  /// Converts Full-width Katakana to Hiragana.
  String toHiragana({String ignore = ''}) {
    return _translate(ignore, k2hTable);
  }

  /// Converts small Hiragana or Katakana to normal size.
  String toNormalKana({String ignore = ''}) {
    return _translate(ignore, smallKana2NormalKana);
  }

  String _convDakuten() {
    String text = this;
    text = text.replaceAll('ｶﾞ', 'ガ').replaceAll('ｷﾞ', 'ギ');
    text = text.replaceAll('ｸﾞ', 'グ').replaceAll('ｹﾞ', 'ゲ');
    text = text.replaceAll('ｺﾞ', 'ゴ').replaceAll('ｻﾞ', 'ザ');
    text = text.replaceAll('ｼﾞ', 'ジ').replaceAll('ｽﾞ', 'ズ');
    text = text.replaceAll('ｾﾞ', 'ゼ').replaceAll('ｿﾞ', 'ゾ');
    text = text.replaceAll('ﾀﾞ', 'ダ').replaceAll('ﾁﾞ', 'ヂ');
    text = text.replaceAll('ﾂﾞ', 'ヅ').replaceAll('ﾃﾞ', 'デ');
    text = text.replaceAll('ﾄﾞ', 'ド').replaceAll('ﾊﾞ', 'バ');
    text = text.replaceAll('ﾋﾞ', 'ビ').replaceAll('ﾌﾞ', 'ブ');
    text = text.replaceAll('ﾍﾞ', 'ベ').replaceAll('ﾎﾞ', 'ボ');
    text = text.replaceAll('ﾊﾟ', 'パ').replaceAll('ﾋﾟ', 'ピ');
    text = text.replaceAll('ﾌﾟ', 'プ').replaceAll('ﾍﾟ', 'ペ');
    text = text.replaceAll('ﾎﾟ', 'ポ').replaceAll('ｳﾞ', 'ヴ');
    return text;
  }

  /// Converts Half-width (Hankaku) characters to Full-width (Zenkaku).
  String toZenkaku({
    bool kana = true,
    bool ascii = false,
    bool digit = false,
    String ignore = '',
  }) {
    Map<int, String> map;
    if (ascii) {
      if (digit) {
        map = kana ? h2zAll : h2zAd;
      } else {
        map = kana ? h2zAk : h2zA;
      }
    } else if (digit) {
      map = kana ? h2zDk : h2zD;
    } else {
      map = kana ? h2zK : const {};
    }

    String text = this;
    if (kana) {
      text = text._convDakuten();
    }
    if (map.isEmpty) return text;
    return text._translate(ignore, map);
  }

  /// Converts Full-width (Zenkaku) characters to Half-width (Hankaku).
  String toHankaku({
    bool kana = true,
    bool ascii = false,
    bool digit = false,
    String ignore = '',
  }) {
    Map<int, String> map;
    if (ascii) {
      if (digit) {
        map = kana ? z2hAll : z2hAd;
      } else {
        map = kana ? z2hAk : z2hA;
      }
    } else if (digit) {
      map = kana ? z2hDk : z2hD;
    } else {
      map = kana ? z2hK : const {};
    }

    if (map.isEmpty) return this;
    return _translate(ignore, map);
  }

  /// Normalizes characters (similar to unicodedata.normalize NFKC but with specific Japanese rules).
  String normalizeKana() {
    String text = this;
    text = text.replaceAll('〜', 'ー').replaceAll('～', 'ー');
    text = text.replaceAll('’', "'").replaceAll('”', '"').replaceAll('“', '"');
    text = text
        .replaceAll('―', '-')
        .replaceAll('‐', '-')
        .replaceAll('˗', '-')
        .replaceAll('֊', '-');
    text = text
        .replaceAll('‐', '-')
        .replaceAll('‑', '-')
        .replaceAll('‒', '-')
        .replaceAll('–', '-');
    text = text
        .replaceAll('⁃', '-')
        .replaceAll('⁻', '-')
        .replaceAll('₋', '-')
        .replaceAll('−', '-');
    text = text
        .replaceAll('﹣', 'ー')
        .replaceAll('－', 'ー')
        .replaceAll('—', 'ー')
        .replaceAll('―', 'ー');
    text = text.replaceAll('━', 'ー').replaceAll('─', 'ー');

    // In Python this calls unicodedata.normalize('NFKC', text)
    // Dart doesn't have a built-in unicode normalizer in the core library that matches NFKC exactly.
    // However, the z2h/h2z and _translate cover a lot. For full NFKC, an external package like `unorm_dart` would be needed.
    // Since we want to stick to core if possible, or we could just use a minimal version that handles fullwidth->halfwidth standard forms.
    // Let's implement the basic ascii/digit normalization as it's the most common NFKC effect.
    text = text.toHankaku(kana: false, ascii: true, digit: true);
    text = text.toZenkaku(kana: true, ascii: false, digit: false);
    return text;
  }

  /// Convert Hiragana/Katakana to Roman-input-style alphabet
  String toAlphabet() {
    String text = toHiragana(); // internally kana2alphabet first converts to hiragana or it expects hiragana

    // We can port the sequence of replaces from kana2alphabet
    text = text
        .replaceAll('きゃ', 'kya')
        .replaceAll('きゅ', 'kyu')
        .replaceAll('きょ', 'kyo');
    text = text
        .replaceAll('ぎゃ', 'gya')
        .replaceAll('ぎゅ', 'gyu')
        .replaceAll('ぎょ', 'gyo');
    text = text
        .replaceAll('しゃ', 'sha')
        .replaceAll('しゅ', 'shu')
        .replaceAll('しょ', 'sho');
    text = text
        .replaceAll('じゃ', 'ja')
        .replaceAll('じゅ', 'ju')
        .replaceAll('じょ', 'jo');
    text = text
        .replaceAll('ちゃ', 'cha')
        .replaceAll('ちゅ', 'chu')
        .replaceAll('ちょ', 'cho');
    text = text
        .replaceAll('にゃ', 'nya')
        .replaceAll('にゅ', 'nyu')
        .replaceAll('にょ', 'nyo');
    text = text
        .replaceAll('ひゃ', 'hya')
        .replaceAll('ひゅ', 'hyu')
        .replaceAll('ひょ', 'hyo');
    text = text
        .replaceAll('ふぁ', 'fa')
        .replaceAll('ふぃ', 'fi')
        .replaceAll('ふぇ', 'fe');
    text = text.replaceAll('ふぉ', 'fo');
    text = text
        .replaceAll('みゃ', 'mya')
        .replaceAll('みゅ', 'myu')
        .replaceAll('みょ', 'myo');
    text = text
        .replaceAll('りゃ', 'rya')
        .replaceAll('りゅ', 'ryu')
        .replaceAll('りょ', 'ryo');
    text = text
        .replaceAll('びゃ', 'bya')
        .replaceAll('びゅ', 'byu')
        .replaceAll('びょ', 'byo');
    text = text
        .replaceAll('ぴゃ', 'pya')
        .replaceAll('ぴゅ', 'pyu')
        .replaceAll('ぴょ', 'pyo');
    text = text
        .replaceAll('が', 'ga')
        .replaceAll('ぎ', 'gi')
        .replaceAll('ぐ', 'gu');
    text = text
        .replaceAll('げ', 'ge')
        .replaceAll('ご', 'go')
        .replaceAll('ざ', 'za');
    text = text
        .replaceAll('じ', 'ji')
        .replaceAll('ず', 'zu')
        .replaceAll('ぜ', 'ze');
    text = text
        .replaceAll('ぞ', 'zo')
        .replaceAll('だ', 'da')
        .replaceAll('ぢ', 'ji');
    text = text
        .replaceAll('づ', 'zu')
        .replaceAll('で', 'de')
        .replaceAll('ど', 'do');
    text = text
        .replaceAll('ば', 'ba')
        .replaceAll('び', 'bi')
        .replaceAll('ぶ', 'bu');
    text = text
        .replaceAll('べ', 'be')
        .replaceAll('ぼ', 'bo')
        .replaceAll('ぱ', 'pa');
    text = text
        .replaceAll('ぴ', 'pi')
        .replaceAll('ぷ', 'pu')
        .replaceAll('ぺ', 'pe');
    text = text.replaceAll('ぽ', 'po');
    text = text
        .replaceAll('か', 'ka')
        .replaceAll('き', 'ki')
        .replaceAll('く', 'ku');
    text = text
        .replaceAll('け', 'ke')
        .replaceAll('こ', 'ko')
        .replaceAll('さ', 'sa');
    text = text
        .replaceAll('し', 'shi')
        .replaceAll('す', 'su')
        .replaceAll('せ', 'se');
    text = text
        .replaceAll('そ', 'so')
        .replaceAll('た', 'ta')
        .replaceAll('ち', 'chi');
    text = text
        .replaceAll('つ', 'tsu')
        .replaceAll('て', 'te')
        .replaceAll('と', 'to');
    text = text
        .replaceAll('な', 'na')
        .replaceAll('に', 'ni')
        .replaceAll('ぬ', 'nu');
    text = text
        .replaceAll('ね', 'ne')
        .replaceAll('の', 'no')
        .replaceAll('は', 'ha');
    text = text
        .replaceAll('ひ', 'hi')
        .replaceAll('ふ', 'fu')
        .replaceAll('へ', 'he');
    text = text
        .replaceAll('ほ', 'ho')
        .replaceAll('ま', 'ma')
        .replaceAll('み', 'mi');
    text = text
        .replaceAll('む', 'mu')
        .replaceAll('め', 'me')
        .replaceAll('も', 'mo');
    text = text
        .replaceAll('ら', 'ra')
        .replaceAll('り', 'ri')
        .replaceAll('る', 'ru');
    text = text.replaceAll('れ', 're').replaceAll('ろ', 'ro');
    text = text
        .replaceAll('や', 'ya')
        .replaceAll('ゆ', 'yu')
        .replaceAll('よ', 'yo');
    text = text
        .replaceAll('わ', 'wa')
        .replaceAll('ゐ', 'wi')
        .replaceAll('を', 'wo');
    text = text.replaceAll('ゑ', 'we');
    text = text
        .replaceAll('ゔぁ', 'va')
        .replaceAll('ゔぃ', 'vi')
        .replaceAll('ゔぅ', 'vuu');
    text = text.replaceAll('ゔぇ', 've').replaceAll('ゔぉ', 'vo');
    text = text
        .replaceAll('ゃ', 'ya')
        .replaceAll('ゅ', 'yu')
        .replaceAll('ょ', 'yo');
    text = text.replaceAll('ぁ', 'a').replaceAll('ぃ', 'i').replaceAll('ぅ', 'u');
    text = text.replaceAll('ぇ', 'e').replaceAll('ぉ', 'o');
    text = text.replaceAll('ゎ', 'wa');
    text = text.replaceAll('ゔ', 'vu');
    text = text.replaceAll('ヵ', 'ka');
    text = text._translate('', kana2Hep);

    // Process sokuon (っ)
    while (text.contains('っ')) {
      final chars = text.split('');
      final tsuPos = chars.indexOf('っ');
      if (chars.length <= tsuPos + 1) {
        text = "${chars.sublist(0, chars.length - 1).join()}xtsu";
      } else if (tsuPos == 0) {
        chars[tsuPos] = 'xtsu';
        text = chars.join();
      } else if (chars[tsuPos + 1] == 'っ') {
        chars[tsuPos] = 'xtsu';
        text = chars.join();
      } else {
        chars[tsuPos] = chars[tsuPos + 1];
        text = chars.join();
      }
    }
    return text;
  }
}
