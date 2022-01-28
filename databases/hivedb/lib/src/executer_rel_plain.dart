import 'package:core/executer.dart';
import 'package:core/model.dart';
import 'package:core/time_tracker.dart';
import 'package:hive/hive.dart';

import 'model.dart';

class ExecutorRelPlain
    extends ExecutorBaseRel<RelSourceEntityPlain, RelTargetEntity> {
  final Box<RelSourceEntityPlain> _store;
  final Box<RelTargetEntity> _boxTarget;

  static Future<ExecutorRelPlain> create(
      TimeTracker tracker, String? path) async {
    if (!Hive.isAdapterRegistered(RelSourceEntityPlainAdapter().typeId)) {
      Hive.registerAdapter(RelSourceEntityPlainAdapter());
    }
    if (!Hive.isAdapterRegistered(RelSourceEntityIndexedAdapter().typeId)) {
      Hive.registerAdapter(RelSourceEntityIndexedAdapter());
    }
    if (!Hive.isAdapterRegistered(RelTargetEntityAdapter().typeId)) {
      Hive.registerAdapter(RelTargetEntityAdapter());
    }
    return ExecutorRelPlain._(
        tracker,
        await Hive.openBox('RelSourceEntityPlain', path: path),
        await Hive.openBox('RelTargetEntity', path: path));
  }

  ExecutorRelPlain._(TimeTracker tracker, this._store, this._boxTarget)
      : super(tracker);

  @override
  Future<void> close() async {
    await _store.close();
    await _boxTarget.close();
  }

  @override
  Future<void> insertData(int relSourceCount, int relTargetCount) async {
    final targets = prepareDataTargets(relTargetCount);
    await _boxTarget.putAll(_itemsById(targets));
    assert(targets.first.id != 0);
    final sources = prepareDataSources(relSourceCount, targets);
    await _store.putAll(_itemsById(sources));
    assert(_store.length == relSourceCount);
    assert(_boxTarget.length == relTargetCount);
  }

  @override
  Future<List<RelSourceEntityPlain>> queryWithLinks(
      List<ConfigQueryWithLinks> args) {
    if (!ExecutorBase.caseSensitive) {
      args.forEach((config) {
        config.sourceStringEquals..toLowerCase();
        config.targetStringEquals..toLowerCase();
      });
    }

    return Future.value(tracker.track('queryWithLinks', () {
      late List<RelSourceEntityPlain> result;
      final length = args.length;
      for (var i = 0; i < length; i++) {
        final matchingTargets = _boxTarget.values
            .where((RelTargetEntity o) =>
                (ExecutorBase.caseSensitive ? o.name : o.name.toLowerCase()) ==
                args[i].targetStringEquals)
            .map((e) => e.id)
            .toSet();
        assert(matchingTargets.isNotEmpty);
        result = _store.values
            .where((RelSourceEntityPlain o) =>
                o.tLong == args[i].sourceIntEquals &&
                matchingTargets.contains((o).relTargetId) &&
                (ExecutorBase.caseSensitive
                        ? o.tString
                        : o.tString.toLowerCase()) ==
                    args[i].sourceStringEquals)
            .toList();
      }
      return result;
    }));
  }

  @override
  RelTargetEntity generateTarget(int id, String name) {
    return RelTargetEntity(id, name);
  }

  @override
  RelSourceEntityPlain generateItem(String tString, int i2, target) {
    return RelSourceEntityPlain.forInsert(tString, i2 % 2, target);
  }
}

Map<int, EntityT> _itemsById<EntityT>(List<EntityWithSettableId> list) {
  final result = <int, EntityT>{};
  var id = 1;
  list.forEach((EntityWithSettableId o) {
    if (o.id == 0) o.id = id++;
    result[o.id] = o as EntityT;
  });
  return result;
}
