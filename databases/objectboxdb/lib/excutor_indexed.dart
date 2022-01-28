import 'dart:io';

import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:objectboxdb/model.dart';
import 'package:objectboxdb/obx_excutor_indexed.dart';

import 'objectbox.g.dart';

class ExecutorObxIndexed extends ExecutorBase<TestEntityIndexed> {
  final Store store;
  final Box<TestEntityIndexed> box;
  final Query<TestEntityIndexed> queryStringEq;
  final void Function(String) queryStringEqSetValue;

  factory ExecutorObxIndexed(Directory dbDir, TimeTracker tracker) {
    final store = Store(getObjectBoxModel(),
        directory: dbDir.path,
        queriesCaseSensitiveDefault: ExecutorBase.caseSensitive);
    late final Query<TestEntityIndexed> queryStringEq;
    late final void Function(String) queryStringEqSetValue;

    final query = store
        .box<TestEntityIndexed>()
        .query(TestEntityIndexed_.tString.equals(''))
        .build();
    final queryParam = query.param(TestEntityIndexed_.tString);
    queryStringEqSetValue = (String val) => queryParam.value = val;
    queryStringEq = query;

    return ExecutorObxIndexed._(
        tracker, store, queryStringEq, queryStringEqSetValue);
  }

  ExecutorObxIndexed._(TimeTracker tracker, this.store, this.queryStringEq,
      this.queryStringEqSetValue)
      : box = store.box(),
        super(tracker);

  @override
  Future<void> close() async => store.close();

  @override
  Future<void> insertMany(List<TestEntityIndexed> items) =>
      Future.value(tracker.track('insertMany', () => box.putMany(items)));

  @override
  Future<void> updateMany(List<TestEntityIndexed> items) =>
      Future.value(tracker.track('updateMany', () => box.putMany(items)));

  @override
  Future<List<TestEntityIndexed>> readAll(List<int> optionalIds) =>
      Future.value(tracker.track('readAll', () => box.getAll()));

  @override
  Future<List<TestEntityIndexed?>> queryById(List<int> ids,
          [String? benchmarkQualifier]) =>
      Future.value(tracker.track(
          'queryById' + (benchmarkQualifier ?? ''), () => box.getMany(ids)));

  @override
  Future<void> removeMany(List<int> ids) =>
      Future.value(tracker.track('removeMany', () => box.removeMany(ids)));

  @override
  Future<List<TestEntityIndexed>> queryStringEquals(List<String> val) =>
      Future.value(tracker.track(
          'queryStringEquals',
          () => store.runInTransaction(TxMode.read, () {
                late List<TestEntityIndexed> result;
                final length = val.length;
                for (var i = 0; i < length; i++) {
                  queryStringEqSetValue(val[i]);
                  result = queryStringEq.find();
                }
                return result;
              })));

  @override
  Future<ExecutorBaseRel> createRelBenchmark() =>
      Future.value(ExecutorRelIndexed(store, tracker));

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
