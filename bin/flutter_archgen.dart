import 'dart:io' as io;

import 'package:flutter_archgen/flutter_archgen.dart';

Future<void> main(List<String> arguments) async {
  io.exitCode = await runFlutterArchgen(arguments);
}
