import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:core/utils.dart';
import 'package:isar/isar.dart';

import 'model.dart';

class ExecutorRelIndexed
    extends ExecutorBaseRel<RelSourceEntityIndexed, RelTargetEntity> {
  final Isar _store;
  final IsarCollection<RelSourceEntityIndexed> _box;
  final IsarCollection<RelTargetEntity> _boxTarget;

  ExecutorRelIndexed(TimeTracker tracker, this._store)
      : _box = _store.getCollection('RelSourceEntityIndexed'),
        _boxTarget = _store.getCollection('RelTargetEntity'),
        super(tracker);

  @override
  Future<void> close() async {
    // Do nothing, store is closed by Executor.
  }

  @override
  Future<void> insertData(int relSourceCount, int relTargetCount) async {
    final targets = prepareDataTargets(relTargetCount);
    assignIds(targets);
    _store.writeTxnSync((isar) => _boxTarget.putAllSync(targets));

    final sources = prepareDataSources(relSourceCount, targets);
    assignIds(sources);
    _store.writeTxnSync((isar) => _box.putAllSync(sources));

    // TODO no count() available in isar yet?
    // assert(_box.length == relSourceCount);
    // assert(_boxTarget.length == relTargetCount);
  }

  @override
  Future<List<RelSourceEntityIndexed>> queryWithLinks(
      List<ConfigQueryWithLinks> args) {
    // TODO implement once the model is properly generated
    // see https://isar.dev/queries#links
    return Future.error(UnimplementedError('queryWithLinks'));
  }

  @override
  RelTargetEntity generateTarget(int id, String name) {
    return RelTargetEntity(id, name);
  }

  @override
  RelSourceEntityIndexed generateItem(String tString, int i2, target) {
    return RelSourceEntityIndexed.forInsert(tString, i2 % 2, target);
  }
}
