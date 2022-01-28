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

  ExecutorPlain._(this._store, TimeTracker tracker)
      : _box = _store.getCollection('TestEntityPlain'),
        super(tracker);

  static Future<ExecutorPlain> create(
      Directory dbDir, TimeTracker tracker) async {
    return ExecutorPlain._(
        await Isar.open(
            schemas: [TestEntityPlainSchema], directory: dbDir.path),
        tracker);
  }

  // TODO isar v0.4.0 - crashes with a SEGFAULT (at least in Android emulator)
  // Future<void> close() async => await _store.close();
  @override
  Future<void> close() async => await _store.close();

  @override
  Future<void> insertMany(List<TestEntityPlain> items) => Future.value(
        tracker.track(
          'insertMany',
          () {
            assignIds(items);
            return _store.writeTxnSync(
              (isar) => _box.putAllSync(items),
            );
          },
        ),
      );

  @override
  Future<void> updateMany(List<TestEntityPlain> items) =>
      Future.value(tracker.track('updateMany',
          () => _store.writeTxnSync((isar) => _box.putAllSync(items))));

  // Note: get all is not supported in isar (v0.4.0), use get by id.
  @override
  Future<List<TestEntityPlain?>> readAll(List<int> optionalIds) => Future.value(
      tracker.track('readAll', () => _box.getAllSync(optionalIds)));

  @override
  Future<List<TestEntityPlain?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      Future.value(tracker.track('queryById' + (benchmarkQualifier ?? ''),
          () => _box.getAllSync(ids)));

  @override
  Future<void> removeMany(List<int> ids) => Future.value(
        tracker.track('removeMany',
            () => _store.writeTxnSync((Isar isar) => _box.deleteAllSync(ids))),
      );

  @override
  Future<List<TestEntityPlain>> queryStringEquals(List<String> val) async =>
      Future.value(tracker.track('queryStringEquals', () {
        tracker.track('queryStringEquals', () {
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
      }));
//todo
  // @override
  // Future<ExecutorBaseRel> createRelBenchmark() => Future.value(indexed
  //     ? ExecutorRel<RelSourceEntityIndexed>._(tracker, _store)
  //     : ExecutorRel<RelSourceEntityPlain>._(tracker, _store));
  //
  // @override
  // T generateIndexed(int i) {
  //   return TestEntityIndexed(0, 'Entity #$i', i, i, i.toDouble()) as T;
  // }
  //
  // @override
  // T generatePlain(int i) {
  //   return TestEntityPlain(0, 'Entity #$i', i, i, i.toDouble()) as T;
  // }
  @override
  Future<ExecutorBaseRel> createRelBenchmark() async =>
      ExecutorRelPlain(tracker, _store);
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
