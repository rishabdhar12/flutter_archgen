import 'dart:io';

import 'package:flutter_archgen/flutter_archgen.dart';
import 'package:test/test.dart';

void main() {
  group('runFlutterArchgen', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_archgen_init_');
      await _writeFlutterPubspec(tempDir, 'sample_app');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('generates the scaffold from the init executable flow', () async {
      final exitCode = await runFlutterArchgen(<String>[
        'init',
        '--app-name',
        'Sample App',
        '--firebase',
        '--crashlytics',
        '--sentry',
        '--remote-config',
        '--notifications',
        '--device-info',
        '--hive',
        '--sqlite',
        '--skip-pub-get',
        '--target-dir',
        tempDir.path,
      ]);

      expect(exitCode, equals(0));
      expect(File('${tempDir.path}/lib/main.dart').existsSync(), isTrue);
      expect(
        File(
          '${tempDir.path}/lib/core/network/services/api_client.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/firebase/app_firebase_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/database/app_database_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/monitoring/sentry_monitoring_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/monitoring/crashlytics_monitoring_service.dart',
        ).existsSync(),
        isTrue,
      );

      final pubspec = File('${tempDir.path}/pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('flutter_riverpod'));
      expect(pubspec, contains('firebase_remote_config'));
      expect(pubspec, contains('firebase_crashlytics'));
      expect(pubspec, contains('sentry_flutter'));
      expect(pubspec, contains('sqflite'));
    });
  });
}

Future<void> _writeFlutterPubspec(Directory directory, String packageName) {
  return File('${directory.path}/pubspec.yaml').writeAsString('''
name: $packageName
description: Test app
environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter

flutter:
''');
}
