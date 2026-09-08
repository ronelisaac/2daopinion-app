import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Iterable<File> sources(String directory) => Directory(directory)
    .listSync(recursive: true)
    .whereType<File>()
    .where((file) => file.path.endsWith('.dart'));

void main() {
  test('Domain has no Flutter, Firebase or infrastructure dependencies', () {
    for (final source in sources('lib/domain')) {
      final imports = RegExp(
        r"import\s+['\x22]([^'\x22]+)['\x22]",
      ).allMatches(source.readAsStringSync()).map((match) => match.group(1)!);
      for (final imported in imports) {
        expect(imported.startsWith('package:'), isFalse, reason: source.path);
        expect(imported.contains('../../'), isFalse, reason: source.path);
      }
    }
  });

  test(
    'Controllers depend on contracts, not concrete repositories or views',
    () {
      for (final source in sources('lib/controllers')) {
        final content = source.readAsStringSync();
        for (final forbidden in [
          "package:firebase_",
          "package:cloud_firestore",
          "../repositories/",
          "../views/",
          "../widgets/",
          "BuildContext",
          "TextEditingController",
        ]) {
          expect(
            content.contains(forbidden),
            isFalse,
            reason: '${source.path}: $forbidden',
          );
        }
      }
    },
  );

  test('Views and widgets cannot access infrastructure directly', () {
    for (final source in [...sources('lib/views'), ...sources('lib/widgets')]) {
      final content = source.readAsStringSync();
      for (final forbidden in [
        "package:firebase_",
        "package:cloud_firestore",
        "/repositories/",
        "dart:io",
        "package:http",
      ]) {
        expect(
          content.contains(forbidden),
          isFalse,
          reason: '${source.path}: $forbidden',
        );
      }
    }
  });
}
