// import 'package:core/executer.dart';
// import 'package:core/time_tracker.dart';
// import 'package:core/utils.dart';
// import 'package:isar/isar.dart';
//
// import 'model.dart';
//
// class ExecutorRelIndexed
//     extends ExecutorBaseRel<RelSourceEntityIndexed, RelTargetEntity> {
//   final Isar _store;
//   final IsarCollection<RelSourceEntityIndexed> _box;
//   final IsarCollection<RelTargetEntity> _boxTarget;
//   final bool useAsync;
//
//   ExecutorRelIndexed(TimeTracker tracker, this._store, this.useAsync)
//       : _box = _store.getCollection('RelSourceEntityIndexed'),
//         _boxTarget = _store.getCollection('RelTargetEntity'),
//         super(tracker);
//
//   @override
//   Future<void> close() async {
//     // Do nothing, store is closed by Executor.
//   }
//
//   @override
//   Future<void> insertData(int relSourceCount, int relTargetCount) async {
//     final targets = prepareDataTargets(relTargetCount);
//     assignIds(targets);
//     if (useAsync) {
//       await _store.writeTxn((isar) => _boxTarget.putAll(targets));
//
//       final sources = prepareDataSources(relSourceCount, targets);
//       assignIds(sources);
//       await _store.writeTxn((isar) => _box.putAll(sources));
//     } else {
//       _store.writeTxnSync((isar) => _boxTarget.putAllSync(targets));
//
//       final sources = prepareDataSources(relSourceCount, targets);
//       assignIds(sources);
//       _store.writeTxnSync((isar) => _box.putAllSync(sources));
//     }
//   }
//
//   @override
//   Future<List<RelSourceEntityIndexed>> queryWithLinks(
//       List<ConfigQueryWithLinks> args) {
//     // TODO implement once the model is properly generated
//     // see https://isar.dev/queries#links
//     return Future.error(UnimplementedError('queryWithLinks'));
//   }
//
//   @override
//   RelTargetEntity generateTarget(int id, String name) {
//     return RelTargetEntity(id, name);
//   }
//
//   @override
//   RelSourceEntityIndexed generateItem(String tString, int i2, target) {
//     return RelSourceEntityIndexed.forInsert(tString, i2 % 2, target);
//   }
// }
