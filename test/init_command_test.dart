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
        '--shorebird',
        '--fastlane',
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
          '${tempDir.path}/lib/core/services/firebase/firestore/firebase_firestore_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/firebase/firestore/firebase_firestore_service_impl.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/firebase/remote_config/firebase_remote_config_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/firebase/remote_config/firebase_remote_config_service_impl.dart',
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
          '${tempDir.path}/lib/core/services/database/app_database_service_impl.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/cache/hive_cache_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/cache/hive_cache_service_impl.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/preferences/app_preferences.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/preferences/app_preferences_impl.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/security/secure_storage_service.dart',
        ).existsSync(),
        isTrue,
      );
      expect(
        File(
          '${tempDir.path}/lib/core/services/security/secure_storage_service_impl.dart',
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
      expect(
        File('${tempDir.path}/tool/release/shorebird/README.md').existsSync(),
        isTrue,
      );
      expect(
        File('${tempDir.path}/shorebird.yaml.example').existsSync(),
        isTrue,
      );
      expect(File('${tempDir.path}/fastlane/Fastfile').existsSync(), isTrue);
      expect(File('${tempDir.path}/fastlane/Appfile').existsSync(), isTrue);
      expect(File('${tempDir.path}/fastlane/README.md').existsSync(), isTrue);
      expect(File('${tempDir.path}/Gemfile').existsSync(), isTrue);

      final pubspec = File('${tempDir.path}/pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('flutter_riverpod'));
      expect(pubspec, contains('firebase_remote_config'));
      expect(pubspec, contains('firebase_crashlytics'));
      expect(pubspec, contains('sentry_flutter'));
      expect(pubspec, contains('sqflite'));
      expect(
        File(
          '${tempDir.path}/lib/core/services/firebase/app_firebase_service.dart',
        ).existsSync(),
        isFalse,
      );
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
