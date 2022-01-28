import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:core/utils.dart';
import 'package:isar/isar.dart';
import 'package:isardb/executor_rel_indexed.dart';
import 'package:isardb/model.dart';

class ExecutorIndexed extends ExecutorBase<TestEntityIndexed> {
  final Isar _store;
  final IsarCollection<TestEntityIndexed> _box;
  final bool useAsync;
  ExecutorIndexed._(this._store, TimeTracker tracker, this.useAsync)
      : _box = _store.getCollection('TestEntityIndexed'),
        super(tracker);

  static Future<ExecutorIndexed> create(
      Directory dbDir, TimeTracker tracker, bool useAsync) async {
    return ExecutorIndexed._(
        await Isar.open(
            schemas: [TestEntityIndexedSchema], directory: dbDir.path),
        tracker,
        useAsync);
  }

  @override
  Future<void> close() async => await _store.close();

  @override
  Future<void> insertMany(List<TestEntityIndexed> items) async => tracker.track(
        'insertMany',
        () async {
          assignIds(items);
          if (useAsync) {
            return await _store.writeTxn(
              (isar) async => _box.putAllSync(items),
            );
          } else {
            return await _store.writeTxnSync(
              (isar) => _box.putAllSync(items),
            );
          }
        },
      );

  @override
  Future<void> updateMany(List<TestEntityIndexed> items) =>
      Future.value(tracker.track('updateMany', () async {
        if (useAsync) {
          await _store.writeTxn((isar) async => _box.putAllSync(items));
        } else {
          _store.writeTxnSync((isar) => _box.putAllSync(items));
        }
      }));

  // Note: get all is not supported in isar (v0.4.0), use get by id.
  @override
  Future<List<TestEntityIndexed?>> readAll(List<int> optionalIds) =>
      Future.value(
          tracker.track('readAll', ()async {
            if(useAsync){
              _box.getAllSync(optionalIds)
            }else{
              _box.getAllSync(optionalIds)
            }
          }));

  @override
  Future<List<TestEntityIndexed?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      Future.value(tracker.track('queryById' + (benchmarkQualifier ?? ''),
          () => _box.getAllSync(ids)));

  @override
  Future<void> removeMany(List<int> ids) => Future.value(
        tracker.track('removeMany',
            () => _store.writeTxnSync((Isar isar) => _box.deleteAllSync(ids))),
      );

  @override
  Future<List<TestEntityIndexed>> queryStringEquals(List<String> val) async =>
      Future.value(tracker.track('queryStringEquals', () {
        // Indexed queries must be case insensitive, this prevents comparison.
        // See https://github.com/isar/isar#queries
        assert(!ExecutorBase.caseSensitive);
        late List<TestEntityIndexed> result;
        final length = val.length;
        for (var i = 0; i < length; i++) {
          result = (_box).where().tStringEqualTo(val[i]).findAllSync();
        }
        return result;
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
      ExecutorRelIndexed(tracker, _store);
  @override
  TestEntityIndexed generateItem(int i) {
    return TestEntityIndexed(
      0,
      'Entity #$i',
      i,
      i,
      i.toDouble(),
    );
  }
}
