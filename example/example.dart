import 'dart:io';

import 'package:flutter_archgen/flutter_archgen.dart';

Future<void> main() async {
  final tempDir = await Directory.systemTemp.createTemp('flutter_archgen_');

  try {
    await _createMockFlutterApp(tempDir);

    final config = GenerationConfig.fromArguments(
      targetDirectory: tempDir,
      flavorCsv: 'dev,prod',
      enableFirebase: false,
      enableRemoteConfig: false,
      enableSentry: true,
      enableCrashlytics: false,
      enableNotifications: true,
      enableDeviceInfo: true,
      enableHive: true,
      enableSqlite: false,
      enableShorebird: false,
      enableFastlane: false,
      force: false,
      skipPubGet: true,
      appName: 'Orbit',
      organization: 'com.example.orbit',
    );

    final summary = await ArchitectureGenerator().generate(config);

    stdout.writeln('Generated ${summary.writtenCount} files.');
    stdout.writeln('Updated ${summary.updatedCount} existing files.');
    stdout.writeln('Output directory: ${tempDir.path}');
    stdout.writeln('');
    stdout.writeln('Sample generated files:');

    for (final path in summary.writtenPaths.take(5)) {
      stdout.writeln('- $path');
    }

    stdout.writeln('');
    stdout.writeln('Next steps:');

    for (final step in summary.nextSteps) {
      stdout.writeln('- $step');
    }
  } finally {
    await tempDir.delete(recursive: true);
  }
}

Future<void> _createMockFlutterApp(Directory directory) async {
  final pubspec = File(
    '${directory.path}${Platform.pathSeparator}pubspec.yaml',
  );

  await pubspec.writeAsString('''
name: orbit
description: Example Flutter app for flutter_archgen.
version: 1.0.0

environment:
  sdk: ">=3.10.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
''');
}
