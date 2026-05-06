import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flutter_archgen/src/generator/architecture_generator.dart';
import 'package:flutter_archgen/src/generator/generation_config.dart';
import 'package:mason_logger/mason_logger.dart';

class InitCommand extends Command<int> {
  InitCommand(this._logger) {
    argParser
      ..addOption('app-name', help: 'Display name used in generated defaults.')
      ..addOption(
        'org',
        help: 'Reserved for platform tooling and package metadata helpers.',
      )
      ..addOption(
        'flavors',
        defaultsTo: 'dev,prod',
        help: 'Comma-separated flavors to generate.',
      )
      ..addFlag(
        'firebase',
        negatable: false,
        help: 'Enable Firebase core wrappers.',
      )
      ..addFlag(
        'remote-config',
        negatable: false,
        help: 'Enable remote config wrapper generation.',
      )
      ..addFlag(
        'sentry',
        negatable: false,
        help: 'Enable Sentry error monitoring scaffolding.',
      )
      ..addFlag(
        'crashlytics',
        negatable: false,
        help: 'Enable Firebase Crashlytics setup and hooks.',
      )
      ..addFlag(
        'notifications',
        negatable: false,
        help: 'Enable local notification scaffolding.',
      )
      ..addFlag(
        'device-info',
        negatable: false,
        help: 'Enable device info service generation.',
      )
      ..addFlag(
        'hive',
        negatable: false,
        help: 'Enable Hive cache service generation.',
      )
      ..addFlag(
        'sqlite',
        negatable: false,
        help: 'Enable SQLite database service generation.',
      )
      ..addFlag(
        'force',
        negatable: false,
        help:
            'Overwrite user-owned files in addition to generator-owned files.',
      )
      ..addFlag(
        'skip-pub-get',
        negatable: false,
        help: 'Skip the post-generation flutter pub get reminder.',
      )
      ..addOption(
        'target-dir',
        defaultsTo: '.',
        help: 'Target Flutter app directory.',
      );
  }

  final Logger _logger;

  @override
  String get description => 'Generate the phase-1 Flutter architecture shell.';

  @override
  String get name => 'init';

  @override
  String get invocation => 'dart run flutter_archgen:init [options]';

  @override
  Future<int> run() async {
    final argResults = this.argResults;
    if (argResults == null) {
      throw UsageException('Missing arguments.', usage);
    }

    late final GenerationConfig config;
    try {
      config = GenerationConfig.fromArguments(
        appName: argResults['app-name'] as String?,
        organization: argResults['org'] as String?,
        flavorCsv: argResults['flavors'] as String? ?? 'dev,prod',
        enableFirebase: argResults['firebase'] as bool? ?? false,
        enableRemoteConfig: argResults['remote-config'] as bool? ?? false,
        enableSentry: argResults['sentry'] as bool? ?? false,
        enableCrashlytics: argResults['crashlytics'] as bool? ?? false,
        enableNotifications: argResults['notifications'] as bool? ?? false,
        enableDeviceInfo: argResults['device-info'] as bool? ?? false,
        enableHive: argResults['hive'] as bool? ?? false,
        enableSqlite: argResults['sqlite'] as bool? ?? false,
        force: argResults['force'] as bool? ?? false,
        skipPubGet: argResults['skip-pub-get'] as bool? ?? false,
        targetDirectory: Directory(argResults['target-dir'] as String? ?? '.'),
      );
    } on FormatException catch (error) {
      throw UsageException(error.message, usage);
    }

    final generator = ArchitectureGenerator(logger: _logger);
    final summary = await generator.generate(config);

    _logger.success(
      'Generated ${summary.writtenCount} files and updated ${summary.updatedCount} files.',
    );

    if (summary.skippedPaths.isNotEmpty) {
      _logger.warn(
        'Skipped ${summary.skippedPaths.length} user-owned file(s).',
      );
      for (final path in summary.skippedPaths) {
        _logger.info('  - $path');
      }
    }

    _logger.info('');
    _logger.info('Next steps:');
    for (final step in summary.nextSteps) {
      _logger.info('  - $step');
    }

    return ExitCode.success.code;
  }
}
