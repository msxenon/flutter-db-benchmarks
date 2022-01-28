import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:objectboxdb/excutor_indexed.dart';
import 'package:objectboxdb/excutor_plain.dart';

ExecutorBase createExecutor(
    bool indexed, Directory dbDir, TimeTracker tracker) {
  if (indexed) {
    return ExecutorObxIndexed(dbDir, tracker);
  } else {
    return ExecutorObxPLain(dbDir, tracker);
  }
}
