import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:core/utils.dart';
import 'package:isar/isar.dart';

import 'executer_rel_plain.dart';
import 'model.dart';

class ExecutorPlain extends ExecutorBase<TestEntityPlain> {
  final Isar _store;
  final IsarCollection<TestEntityPlain> _box;
  final bool useAsync;
  ExecutorPlain._(this._store, TimeTracker tracker, this.useAsync)
      : _box = _store.getCollection('TestEntityPlain'),
        super(tracker);

  static Future<ExecutorPlain> create(
      Directory dbDir, TimeTracker tracker, bool useAsync) async {
    return ExecutorPlain._(
        await Isar.open(schemas: [
          TestEntityPlainSchema,
          RelSourceEntityPlainSchema,
          RelTargetEntitySchema
        ], directory: dbDir.path),
        tracker,
        useAsync);
  }

  @override
  Future<void> close() async => await _store.close();

  @override
  Future<void> insertMany(List<TestEntityPlain> items) async =>
      tracker.trackAsync(
        'insertMany',
        () async {
          assignIds(items);
          if (useAsync) {
            return await _store.writeTxn(
              (isar) => _box.putAll(items),
            );
          } else {
            return _store.writeTxnSync(
              (isar) => _box.putAllSync(items),
            );
          }
        },
      );

  @override
  Future<void> updateMany(List<TestEntityPlain> items) =>
      tracker.trackAsync('updateMany', () async {
        if (useAsync) {
          await _store.writeTxn((isar) => _box.putAll(items));
        } else {
          _store.writeTxnSync((isar) => _box.putAllSync(items));
        }
      });

  // Note: get all is not supported in isar (v0.4.0), use get by id.
  @override
  Future<List<TestEntityPlain?>> readAll(List<int> optionalIds) =>
      tracker.trackAsync('readAll', () async {
        if (useAsync) {
          return await _box.getAll(optionalIds);
        } else {
          return _box.getAllSync(optionalIds);
        }
      });

  @override
  Future<List<TestEntityPlain?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      tracker.trackAsync('queryById' + (benchmarkQualifier ?? ''), () async {
        if (useAsync) {
          return await _box.getAll(ids);
        } else {
          return _box.getAllSync(ids);
        }
      });

  @override
  Future<void> removeMany(List<int> ids) =>
      tracker.trackAsync('removeMany', () async {
        if (useAsync) {
          await _store.writeTxn((Isar isar) => _box.deleteAll(ids));
        } else {
          _store.writeTxnSync((Isar isar) => _box.deleteAllSync(ids));
        }
      });

  @override
  Future<List<TestEntityPlain>> queryStringEquals(List<String> val) async =>
      tracker.trackAsync('queryStringEquals', () async {
        late List<TestEntityPlain> result;
        final length = val.length;
        for (var i = 0; i < length; i++) {
          if (useAsync) {
            result = await (_box)
                .where()
                .filter()
                .tStringEqualTo(val[i],
                    caseSensitive: ExecutorBase.caseSensitive)
                .findAll();
          } else {
            result = (_box)
                .where()
                .filter()
                .tStringEqualTo(val[i],
                    caseSensitive: ExecutorBase.caseSensitive)
                .findAllSync();
          }
        }
        return result;
      });

  @override
  Future<ExecutorBaseRel> createRelBenchmark() async =>
      ExecutorRelPlain(tracker, _store, useAsync);
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
