import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:objectboxdb/model.dart';
import 'package:objectboxdb/obx_executor_plain.dart';

import 'objectbox.g.dart';

class ExecutorObxPLain extends ExecutorBase<TestEntityPlain> {
  final Store store;
  final Box<TestEntityPlain> box;
  final Query<TestEntityPlain> queryStringEq;
  final void Function(String) queryStringEqSetValue;

  factory ExecutorObxPLain(Directory dbDir, TimeTracker tracker) {
    final store = Store(getObjectBoxModel(),
        directory: dbDir.path,
        queriesCaseSensitiveDefault: ExecutorBase.caseSensitive);
    late final Query<TestEntityPlain> queryStringEq;
    late final void Function(String) queryStringEqSetValue;
    final query = store
        .box<TestEntityPlain>()
        .query(TestEntityPlain_.tString.equals(''))
        .build();
    final queryParam = query.param(TestEntityPlain_.tString);
    queryStringEqSetValue = (String val) => queryParam.value = val;
    queryStringEq = query;

    return ExecutorObxPLain._(
        tracker, store, queryStringEq, queryStringEqSetValue);
  }

  ExecutorObxPLain._(TimeTracker tracker, this.store, this.queryStringEq,
      this.queryStringEqSetValue)
      : box = store.box(),
        super(tracker);

  @override
  Future<void> close() async => store.close();

  @override
  Future<void> insertMany(List<TestEntityPlain> items) =>
      Future.value(tracker.track('insertMany', () => box.putMany(items)));

  @override
  Future<void> updateMany(List<TestEntityPlain> items) =>
      Future.value(tracker.track('updateMany', () => box.putMany(items)));

  @override
  Future<List<TestEntityPlain>> readAll(List<int> optionalIds) =>
      Future.value(tracker.track('readAll', () => box.getAll()));

  @override
  Future<List<TestEntityPlain?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      Future.value(tracker.track(
          'queryById' + (benchmarkQualifier ?? ''), () => box.getMany(ids)));

  @override
  Future<void> removeMany(List<int> ids) =>
      Future.value(tracker.track('removeMany', () => box.removeMany(ids)));

  @override
  Future<List<TestEntityPlain>> queryStringEquals(List<String> val) =>
      Future.value(tracker.track(
          'queryStringEquals',
          () => store.runInTransaction(TxMode.read, () {
                late List<TestEntityPlain> result;
                final length = val.length;
                for (var i = 0; i < length; i++) {
                  queryStringEqSetValue(val[i]);
                  result = queryStringEq.find();
                }
                return result;
              })));

  @override
  Future<ExecutorBaseRel> createRelBenchmark() =>
      Future.value(ExecutorRelPlain(store, tracker));

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
