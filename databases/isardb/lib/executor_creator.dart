import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';

import 'executor_indexed.dart';
import 'executor_plain.dart';

Future<ExecutorBase> createExecutor(
    bool indexed, Directory dbDir, TimeTracker tracker,
    [bool useAsync = false]) async {
  if (indexed) {
    return await ExecutorIndexed.create(dbDir, tracker, useAsync);
  } else {
    return await ExecutorPlain.create(dbDir, tracker, useAsync);
  }
}
