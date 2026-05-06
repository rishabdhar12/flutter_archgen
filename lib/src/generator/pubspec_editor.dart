import 'dart:io';

import 'package:flutter_archgen/src/generator/generation_config.dart';
import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

class PubspecEditor {
  PubspecEditor(this._file);

  final File _file;

  Future<int> apply(GenerationConfig config) async {
    final original = await _file.readAsString();
    final editor = YamlEditor(original);

    _ensureSection(editor, 'dependencies');
    _ensureSection(editor, 'dev_dependencies');

    _setDependency(editor, 'dependencies', 'flutter_riverpod', '^2.6.1');
    _setDependency(editor, 'dependencies', 'get_it', '^8.2.0');
    _setDependency(editor, 'dependencies', 'injectable', '^2.5.1');
    _setDependency(editor, 'dependencies', 'equatable', '^2.0.7');
    _setDependency(editor, 'dependencies', 'intl', '^0.20.2');
    _setDependency(editor, 'dependencies', 'shared_preferences', '^2.5.3');
    _setDependency(editor, 'dependencies', 'flutter_secure_storage', '^9.2.4');
    _setDependency(editor, 'dependencies', 'dio', '^5.9.0');
    _setDependency(editor, 'dependencies', 'pretty_dio_logger', '^1.4.0');
    _setDependency(editor, 'dependencies', 'http_parser', '^4.1.2');

    if (config.enableHive) {
      _setDependency(editor, 'dependencies', 'hive', '^2.2.3');
      _setDependency(editor, 'dependencies', 'hive_flutter', '^1.1.0');
      _setDependency(editor, 'dependencies', 'path_provider', '^2.1.5');
    }

    if (config.enableSqlite) {
      _setDependency(editor, 'dependencies', 'sqflite', '^2.4.2');
    }

    if (config.enableFirebase) {
      _setDependency(editor, 'dependencies', 'firebase_core', '^4.7.0');
      _setDependency(editor, 'dependencies', 'firebase_auth', '^6.4.0');
      _setDependency(editor, 'dependencies', 'cloud_firestore', '^6.3.0');
    }

    if (config.enableCrashlytics) {
      _setDependency(editor, 'dependencies', 'firebase_crashlytics', '^5.2.0');
    }

    if (config.enableSentry) {
      _setDependency(editor, 'dependencies', 'sentry_flutter', '^9.19.0');
      _setDependency(
        editor,
        'dev_dependencies',
        'sentry_dart_plugin',
        '^3.0.0',
      );
    }

    if (config.enableRemoteConfig) {
      _setDependency(
        editor,
        'dependencies',
        'firebase_remote_config',
        '^6.4.0',
      );
    }

    if (config.enableNotifications) {
      _setDependency(
        editor,
        'dependencies',
        'flutter_local_notifications',
        '^19.4.0',
      );
      _setDependency(editor, 'dependencies', 'flutter_timezone', '^4.1.1');
      _setDependency(editor, 'dependencies', 'timezone', '^0.10.1');
      if (config.enableFirebase) {
        _setDependency(editor, 'dependencies', 'firebase_messaging', '^16.2.0');
      }
    }

    if (config.enableDeviceInfo) {
      _setDependency(editor, 'dependencies', 'device_info_plus', '^11.5.0');
    }

    _setDependency(editor, 'dev_dependencies', 'build_runner', '^2.5.4');
    _setDependency(
      editor,
      'dev_dependencies',
      'injectable_generator',
      '^2.8.1',
    );
    _setDependency(editor, 'dev_dependencies', 'flutter_lints', '^6.0.0');
    _setDependency(editor, 'dev_dependencies', 'flutter_test', <String, String>{
      'sdk': 'flutter',
    });

    final updated = editor.toString();
    if (updated == original) {
      return 0;
    }

    await _file.writeAsString(updated);
    return 1;
  }

  void _ensureSection(YamlEditor editor, String section) {
    final content = loadYaml(editor.toString()) as YamlMap?;
    if (content == null || content[section] == null) {
      editor.update(<String>[section], <String, Object?>{});
    }
  }

  void _setDependency(
    YamlEditor editor,
    String section,
    String name,
    Object version,
  ) {
    editor.update(<String>[section, name], version);
  }
}
