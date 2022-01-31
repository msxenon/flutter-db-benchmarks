// import 'dart:async';
// import 'dart:io';
//
// import 'package:core/executer.dart';
// import 'package:core/time_tracker.dart';
// import 'package:core/utils.dart';
// import 'package:isar/isar.dart';
// import 'package:isardb/executor_rel_indexed.dart';
// import 'package:isardb/model.dart';
//
// class ExecutorIndexed extends ExecutorBase<TestEntityIndexed> {
//   final Isar _store;
//   final IsarCollection<TestEntityIndexed> _box;
//   final bool useAsync;
//   ExecutorIndexed._(this._store, TimeTracker tracker, this.useAsync)
//       : _box = _store.getCollection('TestEntityIndexed'),
//         super(tracker);
//
//   static Future<ExecutorIndexed> create(
//       Directory dbDir, TimeTracker tracker, bool useAsync) async {
//     return ExecutorIndexed._(
//         await Isar.open(
//             schemas: [TestEntityIndexedSchema], directory: dbDir.path),
//         tracker,
//         useAsync);
//   }
//
//   @override
//   Future<void> close() => _store.close();
//
//   @override
//   FutureOr<void> insertMany(List<TestEntityIndexed> items) => useAsync
//       ? tracker.trackAsync(
//           'insertMany',
//           () {
//             assignIds(items);
//             return _store.writeTxn(
//               (isar) => _box.putAll(items),
//             );
//           },
//         )
//       : tracker.track('insertMany', () {
//           assignIds(items);
//           return _store.writeTxnSync(
//             (isar) => _box.putAllSync(items),
//           );
//         });
//
//   @override
//   FutureOr<void> updateMany(List<TestEntityIndexed> items) => useAsync
//       ? tracker.trackAsync('updateMany', () {
//           return _store.writeTxn((isar) => _box.putAll(items));
//         })
//       : tracker.track('updateMany', () {
//           _store.writeTxnSync((isar) => _box.putAllSync(items));
//         });
//
//   // Note: get all is not supported in isar (v0.4.0), use get by id.
//   @override
//   FutureOr<List<TestEntityIndexed?>> readAll(List<int> optionalIds) => useAsync
//       ? tracker.trackAsync('readAll', () {
//           return _box.getAll(optionalIds);
//         })
//       : tracker.track('readAll', () {
//           return _box.getAllSync(optionalIds);
//         });
//
//   @override
//   FutureOr<List<TestEntityIndexed?>> queryById(List<int> ids,
//           [String? benchmarkQualifier]) =>
//       useAsync
//           ? tracker.trackAsync('queryById' + (benchmarkQualifier ?? ''), () {
//               return _box.getAll(ids);
//             })
//           : tracker.track('queryById' + (benchmarkQualifier ?? ''), () {
//               return _box.getAllSync(ids);
//             });
//
//   @override
//   FutureOr<void> removeMany(List<int> ids) => useAsync
//       ? tracker.trackAsync('removeMany', () {
//           return _store.writeTxn((Isar isar) => _box.deleteAll(ids));
//         })
//       : tracker.track('removeMany', () {
//           _store.writeTxnSync((Isar isar) => _box.deleteAllSync(ids));
//         });
//
//   @override
//   FutureOr<List<TestEntityIndexed>> queryStringEquals(List<String> val) =>
//       useAsync
//           ? tracker.trackAsync('queryStringEquals', () async {
//               // Indexed queries must be case insensitive, this prevents comparison.
//               // See https://github.com/isar/isar#queries
//               assert(!ExecutorBase.caseSensitive);
//               late List<TestEntityIndexed> result;
//               final length = val.length;
//               for (var i = 0; i < length; i++) {
//                 result = await _box.where().tStringEqualTo(val[i]).findAll();
//               }
//               return result;
//             })
//           : tracker.track('queryStringEquals', () {
//               // Indexed queries must be case insensitive, this prevents comparison.
//               // See https://github.com/isar/isar#queries
//               assert(!ExecutorBase.caseSensitive);
//               late List<TestEntityIndexed> result;
//               final length = val.length;
//               for (var i = 0; i < length; i++) {
//                 result = _box.where().tStringEqualTo(val[i]).findAllSync();
//               }
//               return result;
//             });
//
//   @override
//   FutureOr<ExecutorBaseRel> createRelBenchmark() =>
//       ExecutorRelIndexed(tracker, _store, useAsync);
//   @override
//   TestEntityIndexed generateItem(int i) {
//     return TestEntityIndexed(
//       0,
//       'Entity #$i',
//       i,
//       i,
//       i.toDouble(),
//     );
//   }
// }
