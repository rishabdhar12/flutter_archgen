import 'package:args/command_runner.dart';
import 'package:flutter_archgen/src/cli/init_command.dart';
import 'package:mason_logger/mason_logger.dart';

class FlutterArchgenCommandRunner extends CommandRunner<int> {
  FlutterArchgenCommandRunner({Logger? logger})
    : _logger = logger ?? Logger(),
      super(
        'flutter_archgen',
        'Generate a reusable Flutter architecture shell.',
      ) {
    addCommand(InitCommand(_logger));
  }

  final Logger _logger;
}

Future<int> runFlutterArchgen(List<String> arguments, {Logger? logger}) async {
  final resolvedLogger = logger ?? Logger();
  final runner = FlutterArchgenCommandRunner(logger: resolvedLogger);

  try {
    return await runner.run(arguments) ?? ExitCode.success.code;
  } on UsageException catch (error) {
    resolvedLogger.err(error.message);
    resolvedLogger.info(error.usage);
    return ExitCode.usage.code;
  } catch (error, stackTrace) {
    resolvedLogger.err(error.toString());
    resolvedLogger.detail(stackTrace.toString());
    return ExitCode.software.code;
  }
}
