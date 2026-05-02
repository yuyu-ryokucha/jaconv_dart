import 'package:test/test.dart';
import 'package:jaconv_dart/jaconv_dart.dart';

void main() {
  group('jaconv string extensions', () {
    test('toKatakana', () {
      expect('ともえまみ'.toKatakana(), 'トモエマミ');
      expect('まどまぎ'.toKatakana(ignore: 'ど'), 'マどマギ');
    });

    test('toHankakuKatakana', () {
      expect('ともえまみ'.toHankakuKatakana(), 'ﾄﾓｴﾏﾐ');
      expect('ともえまみ'.toHankakuKatakana(ignore: 'み'), 'ﾄﾓｴﾏみ');
    });

    test('toHiragana', () {
      expect('巴マミ'.toHiragana(), '巴まみ');
      expect('マミサン'.toHiragana(ignore: 'ン'), 'まみさン');
    });

    test('toNormalKana', () {
      expect('さくらきょうこ'.toNormalKana(), 'さくらきようこ');
      expect('キュゥべえ'.toNormalKana(), 'キユウべえ');
    });

    test('toZenkaku', () {
      expect('ﾃｨﾛﾌｨﾅｰﾚ'.toZenkaku(), 'ティロフィナーレ');
      expect('ﾃｨﾛﾌｨﾅｰﾚ'.toZenkaku(ignore: 'ｨ'), 'テｨロフｨナーレ');
      expect(
        'abcd'.toZenkaku(ascii: true, kana: false),
        'ａｂｃｄ',
      ); // Note: python test uses ＡＢＣＤ, but let's check fullwidth ascii.
      // Full width 'a' is 'ａ', so it should be lowercase if input is lowercase.
      // Wait, python's jaconv uses A-Z for a-z? No, it uses matching case.
      expect('1234'.toZenkaku(digit: true, kana: false), '１２３４');
    });

    test('toHankaku', () {
      expect('ティロフィナーレ'.toHankaku(), 'ﾃｨﾛﾌｨﾅｰﾚ');
      expect('ティロフィナーレ'.toHankaku(ignore: 'ィ'), 'ﾃィﾛﾌィﾅｰﾚ');
      expect('ＡＢＣＤ'.toHankaku(ascii: true, kana: false), 'ABCD');
      expect('１２３４'.toHankaku(digit: true, kana: false), '1234');
    });

    test('normalizeKana', () {
      expect('ﾃｨﾛ･フィナ〜レ'.normalizeKana(), 'ティロ・フィナーレ');
    });

    test('toAlphabet', () {
      expect('まみさん'.toAlphabet(), 'mamisan');
      expect('マミサン'.toAlphabet(), 'mamisan');
    });
  });
}
