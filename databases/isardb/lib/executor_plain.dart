import 'dart:async';
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

  // @override
  // Future<void> close() => _store.close();

  @override
  FutureOr<void> insertMany(List<TestEntityPlain> items) => useAsync
      ? tracker.trackAsync(
          'insertMany',
          () {
            assignIds(items);
            return _store.writeTxn(
              (isar) => _box.putAll(items),
            );
          },
        )
      : tracker.track('insertMany', () {
          assignIds(items);

          return _store.writeTxnSync(
            (isar) => _box.putAllSync(items),
          );
        });

  @override
  FutureOr<void> updateMany(List<TestEntityPlain> items) => useAsync
      ? tracker.trackAsync('updateMany', () {
          return _store.writeTxn((isar) => _box.putAll(items));
        })
      : tracker.track('updateMany', () {
          _store.writeTxnSync((isar) => _box.putAllSync(items));
        });

  // Note: get all is not supported in isar (v0.4.0), use get by id.
  @override
  FutureOr<List<TestEntityPlain?>> readAll(List<int> optionalIds) => useAsync
      ? tracker.trackAsync('readAll', () {
          return _box.getAll(optionalIds);
        })
      : tracker.track('readAll', () {
          return _box.getAllSync(optionalIds);
        });

  @override
  FutureOr<List<TestEntityPlain?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      useAsync
          ? tracker.trackAsync('queryById' + (benchmarkQualifier ?? ''), () {
              return _box.getAll(ids);
            })
          : tracker.track('queryById' + (benchmarkQualifier ?? ''), () {
              return _box.getAllSync(ids);
            });

  @override
  FutureOr<void> removeMany(List<int> ids) => useAsync
      ? tracker.trackAsync('removeMany', () {
          return _store.writeTxn((Isar isar) => _box.deleteAll(ids));
        })
      : tracker.track('removeMany', () {
          _store.writeTxnSync((Isar isar) => _box.deleteAllSync(ids));
        });

  @override
  FutureOr<List<TestEntityPlain>> queryStringEquals(List<String> val) =>
      useAsync
          ? tracker.trackAsync('queryStringEquals', () async {
              late List<TestEntityPlain> result;
              final length = val.length;
              for (var i = 0; i < length; i++) {
                result = await (_box)
                    .where()
                    .filter()
                    .tStringEqualTo(val[i],
                        caseSensitive: ExecutorBase.caseSensitive)
                    .findAll();
              }
              return result;
            })
          : tracker.track('queryStringEquals', () {
              late List<TestEntityPlain> result;
              final length = val.length;
              for (var i = 0; i < length; i++) {
                result = (_box)
                    .where()
                    .filter()
                    .tStringEqualTo(val[i],
                        caseSensitive: ExecutorBase.caseSensitive)
                    .findAllSync();
              }
              return result;
            });

  @override
  FutureOr<ExecutorBaseRel> createRelBenchmark() =>
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

  @override
  Future<void> close() async {
    return;
  }
}
