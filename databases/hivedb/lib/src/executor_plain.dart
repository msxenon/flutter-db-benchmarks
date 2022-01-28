import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:hive/hive.dart';

import 'executer_rel_plain.dart';
import 'model.dart';

class ExecutorPlain extends ExecutorBase<TestEntityPlain> {
  final Box<TestEntityPlain> _box;
  final String _dir;
  static Future<ExecutorPlain> create(
      Directory dbDir, TimeTracker tracker) async {
    Hive.init(dbDir.path);
    if (!Hive.isAdapterRegistered(TestEntityPlainAdapter().typeId)) {
      Hive.registerAdapter(TestEntityPlainAdapter());
    }
    if (!Hive.isAdapterRegistered(TestEntityIndexedAdapter().typeId)) {
      Hive.registerAdapter(TestEntityIndexedAdapter());
    }
    return ExecutorPlain._(dbDir.path,
        await Hive.openBox('TestEntityPlain', path: dbDir.path), tracker);
  }

  ExecutorPlain._(this._dir, this._box, TimeTracker tracker) : super(tracker);

  @override
  Future<void> close() async => await _box.close();

  @override
  Future<void> insertMany(List<TestEntityPlain> items) =>
      tracker.trackAsync('insertMany', () async {
        int id = 1;
        final itemsById = <int, TestEntityPlain>{};
        for (var o in items) {
          if (o.id == 0) o.id = id++;
          itemsById[o.id] = o;
        }
        return await _box.putAll(itemsById);
      });

  @override
  Future<void> updateMany(List<TestEntityPlain> items) =>
      Future.value(tracker.trackAsync('updateMany',
          () async => await _box.putAll({for (var o in items) o.id: o})));

  // Note: get all is not supported in isar (v0.4.0), use get by id.
  @override
  Future<List<TestEntityPlain?>> readAll(List<int> optionalIds) =>
      Future.value(tracker.track('readAll', () => _box.values.toList()));

  @override
  Future<List<TestEntityPlain?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      Future.value(tracker.track('queryById' + (benchmarkQualifier ?? ''),
          () => ids.map(_box.get).toList()));

  @override
  Future<void> removeMany(List<int> ids) async =>
      tracker.trackAsync('removeMany', () async {
        await _box.deleteAll(ids);
        await _box.compact();
      });

  @override
  Future<List<TestEntityPlain>> queryStringEquals(List<String> val) async {
    if (!ExecutorBase.caseSensitive) {
      val = val.map((e) => e.toLowerCase()).toList(growable: false);
    }
    return Future.value(tracker.track('queryStringEquals', () {
      late List<TestEntityPlain> result;
      final length = val.length;
      for (var i = 0; i < length; i++) {
        result = _box.values
            .where((TestEntityPlain object) => ExecutorBase.caseSensitive
                ? object.tString == val[i]
                : object.tString.toLowerCase() == val[i])
            .toList();
      }
      return result;
    }));
  }

  @override
  Future<ExecutorBaseRel> createRelBenchmark() async =>
      ExecutorRelPlain.create(tracker, _dir);
  @override
  TestEntityPlain generateItem(int i) {
    return TestEntityPlain(
      0,
      'Entity #$i',
      i,
      i,
      i.toDouble(),
    );
  }
}
