import 'dart:io';

import 'package:flutter_archgen/src/generator/file_manifest.dart';
import 'package:flutter_archgen/src/generator/generation_config.dart';
import 'package:flutter_archgen/src/generator/pubspec_editor.dart';
import 'package:flutter_archgen/src/templates/template_catalog.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

class ArchitectureGenerator {
  ArchitectureGenerator({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  Future<GenerationSummary> generate(GenerationConfig config) async {
    final pubspecFile = File(
      path.join(config.targetDirectory.path, 'pubspec.yaml'),
    );
    if (!await pubspecFile.exists()) {
      throw StateError(
        'No pubspec.yaml found in ${config.targetDirectory.path}. Run inside a Flutter app.',
      );
    }

    final pubspec = await _readPubspec(pubspecFile);
    _validateFlutterProject(pubspec, config.targetDirectory.path);

    final packageName = _readPackageName(pubspec);
    final appName = config.appName?.trim().isNotEmpty == true
        ? config.appName!.trim()
        : ReCase(packageName).titleCase;

    final resolvedConfig = ResolvedGenerationConfig(
      config: config,
      appName: appName,
      packageName: packageName,
    );

    var updatedCount = 0;
    updatedCount += await PubspecEditor(pubspecFile).apply(config);

    final files = TemplateCatalog().build(resolvedConfig);
    final writtenPaths = <String>[];
    final skippedPaths = <String>[];

    for (final generatedFile in files) {
      final target = File(
        path.join(config.targetDirectory.path, generatedFile.path),
      );
      await target.parent.create(recursive: true);

      if (generatedFile.appendIfExists) {
        final result = await _appendIfNeeded(target, generatedFile);
        if (result) {
          updatedCount += 1;
        }
        continue;
      }

      if (await target.exists()) {
        final existing = await target.readAsString();
        final isOwned = existing.contains(generatedFile.ownershipMarker);
        if (!config.force && !isOwned) {
          skippedPaths.add(generatedFile.path);
          continue;
        }
      }

      await target.writeAsString(generatedFile.contents);
      writtenPaths.add(generatedFile.path);
      _logger.detail('Wrote ${generatedFile.path}');
    }

    return GenerationSummary(
      skippedPaths: skippedPaths,
      writtenPaths: writtenPaths,
      updatedCount: updatedCount,
      nextSteps: <String>[
        if (!config.skipPubGet) 'run `flutter pub get`',
        'run `dart run build_runner build --delete-conflicting-outputs`',
        if (config.enableFirebase)
          'add Firebase config files for each platform',
        if (config.enableCrashlytics)
          're-run `flutterfire configure` so Crashlytics platform setup stays in sync',
        if (config.enableSentry)
          'set `SENTRY_DSN` and fill `sentry.properties` before uploading release symbols',
        'wire app-specific routes and features',
        'run `flutter analyze`',
      ],
    );
  }

  Future<bool> _appendIfNeeded(File file, GeneratedFile generatedFile) async {
    if (!await file.exists()) {
      await file.writeAsString(generatedFile.contents);
      return true;
    }

    final existing = await file.readAsString();
    if (existing.contains(generatedFile.ownershipMarker)) {
      return false;
    }

    final separator = existing.trimRight().isEmpty ? '' : '\n\n';
    await file.writeAsString('$existing$separator${generatedFile.contents}');
    return true;
  }

  String _readPackageName(YamlMap? parsed) {
    final packageName = parsed?['name']?.toString().trim();
    if (packageName == null || packageName.isEmpty) {
      throw StateError('Unable to determine the target app package name.');
    }
    return packageName;
  }

  Future<YamlMap?> _readPubspec(File pubspecFile) async {
    return loadYaml(await pubspecFile.readAsString()) as YamlMap?;
  }

  void _validateFlutterProject(YamlMap? pubspec, String targetDirectory) {
    final dependencies = pubspec?['dependencies'];
    if (dependencies is! YamlMap) {
      throw StateError(
        'No Flutter dependency section found in $targetDirectory/pubspec.yaml.',
      );
    }

    final flutter = dependencies['flutter'];
    if (flutter is! YamlMap || flutter['sdk'] != 'flutter') {
      throw StateError(
        'The target project at $targetDirectory is not a Flutter app. Expected `dependencies.flutter.sdk: flutter`.',
      );
    }
  }
}

class GenerationSummary {
  const GenerationSummary({
    required this.skippedPaths,
    required this.writtenPaths,
    required this.updatedCount,
    required this.nextSteps,
  });

  final List<String> nextSteps;
  final List<String> skippedPaths;
  final int updatedCount;
  final List<String> writtenPaths;

  int get writtenCount => writtenPaths.length;
}

class ResolvedGenerationConfig {
  const ResolvedGenerationConfig({
    required this.config,
    required this.appName,
    required this.packageName,
  });

  final String appName;
  final GenerationConfig config;
  final String packageName;
}
