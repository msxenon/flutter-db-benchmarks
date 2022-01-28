import 'dart:math';

import 'model.dart';
import 'time_tracker.dart';

class ConfigQueryWithLinks {
  final String sourceStringEquals;
  final int sourceIntEquals;
  final String targetStringEquals;

  ConfigQueryWithLinks(
      this.sourceStringEquals, this.sourceIntEquals, this.targetStringEquals);
}

abstract class ExecutorBase<T extends TestEntity> {
  static const caseSensitive = true;

  final TimeTracker tracker;

  ExecutorBase(this.tracker);

  Future<void> close();

  T generateItem(int i);
//    ? TestEntityIndexed(0, 'Entity #$i', i, i, i.toDouble()) as T
//           : TestEntityPlain(0, 'Entity #$i', i, i, i.toDouble()) as T,
  List<T> prepareData(int count) =>
      List.generate(count, (i) => generateItem(i), growable: false);

  void changeValues(List<T> items) => items.forEach((item) => item.tLong *= 2);

  List<T> allNotNull(List<T?> items) =>
      items.map((e) => e!).toList(growable: false);

  /// If available should use a read all function,
  /// otherwise use the ID list to look up all items.
  Future<List<T?>> readAll(List<int> optionalIds) => throw UnimplementedError();

  Future<void> insertMany(List<T> items);

  Future<void> updateMany(List<T> items);

  Future<List<T?>> queryById(List<int> ids, [String? benchmarkQualifier]);

  Future<void> removeMany(List<int> ids);

  Future<List<T>> queryStringEquals(List<String> val) =>
      throw UnimplementedError();

  /// Verifies that the executor works as expected (returns proper results).
  Future<void> test({required int count, String? qString}) =>
      Future.sync(() async {
        final checkCount = (String message, Iterable list, int count) =>
            RangeError.checkValueInInterval(list.length, count, count, message);

        final inserts = prepareData(count);
        await insertMany(inserts as List<T>);

        final ids = inserts.map((e) => e.id).toList(growable: false);
        checkCount('insertMany assigns ids', ids.toSet(), count);

        final items = allNotNull(await queryById(ids));
        checkCount('queryById', items, count);

        final itemsAll = allNotNull(await readAll(ids));
        checkCount('readAll', itemsAll, count);

        changeValues(items);
        await updateMany(items);

        if (qString != null) {
          checkCount('query string', await queryStringEquals([qString]), 1);
        }

        checkCount('count before remove',
            (await queryById(ids)).where((e) => e != null), count);
        await removeMany(ids);
        checkCount('count after remove',
            (await queryById(ids)).where((e) => e != null), 0);
      });

  Future<ExecutorBaseRel> createRelBenchmark() => throw UnimplementedError();
}

/// Benchmark executor base class for relations tests
abstract class ExecutorBaseRel<T extends RelSourceEntity,
    S extends EntityWithSettableId> {
  final TimeTracker tracker;

  ExecutorBaseRel(this.tracker);

  Future<void> close();

  /// About 100 sources have the same group so group query condition
  /// returns about 100 results regardless of source object count.
  static int distinctSourceStrings(int sourceObjectCount) =>
      max(1, sourceObjectCount ~/ 100);

  /// Creates repeating group + target combination blocks
  /// where for the first distinctSourceStrings sources
  /// the group number and target number match.
  /// So overall there exist up to count / targets.length blocks
  /// == sources where group and target number match.
  /// The int is 0 or 1 based on the source index being even or odd.
  /// So the block length = targets.length should be odd to make sure
  /// every other block has a different int + group + target combination.

  T generateItem(String tString, int i2, dynamic target);
  List<T> prepareDataSources(int count, List<S> targets) =>
      List.generate(count, (i) {
        // Start source group number at 0 again if multiple
        // of target.length (= next block) reached to ensure
        // each block starts with matching group and target numbers.
        final groupNumber = i % targets.length % distinctSourceStrings(count);
        final string = 'Source group #$groupNumber';
        final target = targets[i % targets.length];
        // Every other source has int 0 or 1
        return generateItem(string, i % 2, target);
      }, growable: false);

  List<S> prepareDataTargets(int count) => List.generate(
      count,
      (i) =>
          generateTarget(0, 'Target #$i'), // RelTargetEntity(0, 'Target #$i'),
      growable: false);
  S generateTarget(int id, String name);
  Future<void> insertData(int relSourceCount, int relTargetCount);

  Future<List<T>> queryWithLinks(List<ConfigQueryWithLinks> args) =>
      throw UnimplementedError();
}
