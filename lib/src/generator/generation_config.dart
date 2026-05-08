import 'dart:io';

class GenerationConfig {
  static final RegExp _validFlavorPattern = RegExp(r'^[a-z][a-z0-9_]*$');

  const GenerationConfig({
    required this.targetDirectory,
    required this.flavors,
    required this.enableFirebase,
    required this.enableRemoteConfig,
    required this.enableSentry,
    required this.enableCrashlytics,
    required this.enableNotifications,
    required this.enableDeviceInfo,
    required this.enableHive,
    required this.enableSqlite,
    required this.enableShorebird,
    required this.enableFastlane,
    required this.force,
    required this.skipPubGet,
    this.appName,
    this.organization,
  });

  factory GenerationConfig.fromArguments({
    required Directory targetDirectory,
    required String flavorCsv,
    required bool enableFirebase,
    required bool enableRemoteConfig,
    required bool enableSentry,
    required bool enableCrashlytics,
    required bool enableNotifications,
    required bool enableDeviceInfo,
    required bool enableHive,
    required bool enableSqlite,
    bool enableShorebird = false,
    bool enableFastlane = false,
    required bool force,
    required bool skipPubGet,
    String? appName,
    String? organization,
  }) {
    final flavors = flavorCsv
        .split(',')
        .map((entry) => entry.trim())
        .where((entry) => entry.isNotEmpty)
        .toSet()
        .toList();

    for (final flavor in flavors) {
      if (!_validFlavorPattern.hasMatch(flavor)) {
        throw FormatException(
          'Invalid flavor "$flavor". Use lowercase letters, numbers, and underscores only.',
        );
      }
    }

    return GenerationConfig(
      targetDirectory: targetDirectory,
      flavors: flavors.isEmpty ? const <String>['dev', 'prod'] : flavors,
      enableFirebase: enableFirebase || enableRemoteConfig || enableCrashlytics,
      enableRemoteConfig: enableRemoteConfig,
      enableSentry: enableSentry,
      enableCrashlytics: enableCrashlytics,
      enableNotifications: enableNotifications,
      enableDeviceInfo: enableDeviceInfo,
      enableHive: enableHive,
      enableSqlite: enableSqlite,
      enableShorebird: enableShorebird,
      enableFastlane: enableFastlane,
      force: force,
      skipPubGet: skipPubGet,
      appName: appName,
      organization: organization,
    );
  }

  final String? appName;
  final bool enableDeviceInfo;
  final bool enableCrashlytics;
  final bool enableFastlane;
  final bool enableFirebase;
  final bool enableHive;
  final bool enableNotifications;
  final bool enableRemoteConfig;
  final bool enableShorebird;
  final bool enableSentry;
  final bool enableSqlite;
  final bool force;
  final List<String> flavors;
  final String? organization;
  final bool skipPubGet;
  final Directory targetDirectory;
}
