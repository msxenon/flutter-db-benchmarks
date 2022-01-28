import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';

import 'executor_plain.dart';

Future<ExecutorBase> createExecutor(
    Directory dbDir, TimeTracker tracker) async {
  return await ExecutorPlain.create(dbDir, tracker);
}
