import 'dart:io';
import 'package:args/args.dart';
import 'package:jaconv_dart/jaconv_dart.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag('to-katakana', help: 'Convert Hiragana to Full-width Katakana.')
    ..addFlag(
      'to-hankaku-katakana',
      help: 'Convert Hiragana to Half-width Katakana.',
    )
    ..addFlag('to-hiragana', help: 'Convert Full-width Katakana to Hiragana.')
    ..addFlag('to-normal-kana', help: 'Convert small Kana to normal Kana.')
    ..addFlag('to-zenkaku', help: 'Convert Half-width to Full-width.')
    ..addFlag('to-hankaku', help: 'Convert Full-width to Half-width.')
    ..addFlag('to-alphabet', help: 'Convert Kana to Alphabet.')
    ..addFlag('normalize', help: 'Normalize text.')
    ..addFlag(
      'ascii',
      help: 'Use with to-zenkaku or to-hankaku to convert ASCII.',
      defaultsTo: false,
    )
    ..addFlag(
      'digit',
      help: 'Use with to-zenkaku or to-hankaku to convert Digits.',
      defaultsTo: false,
    )
    ..addFlag(
      'kana',
      help: 'Use with to-zenkaku or to-hankaku to convert Kana.',
      defaultsTo: true,
    )
    ..addOption(
      'ignore',
      help: 'Characters to ignore during conversion.',
      defaultsTo: '',
    );

  try {
    final argResults = parser.parse(arguments);

    if (argResults['help'] as bool) {
      print('Usage: jaconv [options] [file]');
      print('If no file is provided, it reads from standard input.');
      print(parser.usage);
      exit(0);
    }

    String input = '';
    if (argResults.rest.isNotEmpty) {
      final file = File(argResults.rest.first);
      if (await file.exists()) {
        input = await file.readAsString();
      } else {
        stderr.writeln('Error: File not found: \${argResults.rest.first}');
        exit(1);
      }
    } else {
      // Read from stdin (pipe)
      final stdinLines = await stdin
          .transform(const SystemEncoding().decoder)
          .toList();
      input = stdinLines.join();
    }

    if (input.isEmpty) return;

    final ignoreStr = argResults['ignore'] as String;
    String result = input;

    if (argResults['to-katakana'] as bool) {
      result = result.toKatakana(ignore: ignoreStr);
    } else if (argResults['to-hankaku-katakana'] as bool) {
      result = result.toHankakuKatakana(ignore: ignoreStr);
    } else if (argResults['to-hiragana'] as bool) {
      result = result.toHiragana(ignore: ignoreStr);
    } else if (argResults['to-normal-kana'] as bool) {
      result = result.toNormalKana(ignore: ignoreStr);
    } else if (argResults['to-zenkaku'] as bool) {
      result = result.toZenkaku(
        kana: argResults['kana'] as bool,
        ascii: argResults['ascii'] as bool,
        digit: argResults['digit'] as bool,
        ignore: ignoreStr,
      );
    } else if (argResults['to-hankaku'] as bool) {
      result = result.toHankaku(
        kana: argResults['kana'] as bool,
        ascii: argResults['ascii'] as bool,
        digit: argResults['digit'] as bool,
        ignore: ignoreStr,
      );
    } else if (argResults['to-alphabet'] as bool) {
      result = result.toAlphabet();
    } else if (argResults['normalize'] as bool) {
      result = result.normalizeKana();
    }

    stdout.write(result);
  } catch (e) {
    stderr.writeln('Error: \$e');
    print(parser.usage);
    exit(1);
  }
}
