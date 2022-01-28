import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:objectboxdb/model.dart';

import 'objectbox.g.dart';

class ExecutorRelIndexed
    extends ExecutorBaseRel<RelSourceEntityIndexed, RelTargetEntity> {
  final Store store;
  final Box<RelSourceEntityIndexed> box;
  final Query<RelSourceEntityIndexed> query;
  final void Function(String, int, String) querySetParams;

  factory ExecutorRelIndexed(Store store, TimeTracker tracker) {
    late final void Function(String, int, String) querySetParams;
    late final Query<RelSourceEntityIndexed> queryT;

    final query = (store.box<RelSourceEntityIndexed>().query(
            RelSourceEntityIndexed_.tString.equals('') &
                RelSourceEntityIndexed_.tLong.equals(0))
          ..link(RelSourceEntityIndexed_.obxRelTarget,
              RelTargetEntity_.name.equals('')))
        .build();
    final queryParam1 = query.param(RelSourceEntityIndexed_.tString);
    final queryParam2 = query.param(RelSourceEntityIndexed_.tLong);
    final queryParam3 = query.param(RelTargetEntity_.name);
    querySetParams = (String sourceStringEquals, int sourceIntEquals,
        String targetStringEquals) {
      queryParam1.value = sourceStringEquals;
      queryParam2.value = sourceIntEquals;
      queryParam3.value = targetStringEquals;
    };
    queryT = query;

    return ExecutorRelIndexed._(tracker, store, queryT, querySetParams);
  }

  ExecutorRelIndexed._(
      TimeTracker tracker, this.store, this.query, this.querySetParams)
      : box = store.box(),
        super(tracker);

  @override
  Future<void> close() async {
    // Do nothing, store is closed by Executor.
  }

  @override
  Future<void> insertData(int relSourceCount, int relTargetCount) =>
      Future.sync(() {
        final targets = prepareDataTargets(relTargetCount);
        store.box<RelTargetEntity>().putMany(targets);
        final sources = prepareDataSources(relSourceCount, targets);
        box.putMany(sources);
        assert(box.count() == relSourceCount);
        assert(store.box<RelTargetEntity>().count() == relTargetCount);
      });

  @override
  Future<List<RelSourceEntityIndexed>> queryWithLinks(
          List<ConfigQueryWithLinks> args) =>
      Future.value(tracker.track(
          'queryWithLinks',
          () => store.runInTransaction(TxMode.read, () {
                late List<RelSourceEntityIndexed> result;
                final length = args.length;
                for (var i = 0; i < length; i++) {
                  querySetParams(args[i].sourceStringEquals,
                      args[i].sourceIntEquals, args[i].targetStringEquals);
                  result = query.find();
                }
                return result;
              })));

  @override
  RelTargetEntity generateTarget(int id, String name) {
    return RelTargetEntity(id, name);
  }

  @override
  RelSourceEntityIndexed generateItem(String tString, int i2, target) {
    return RelSourceEntityIndexed.forInsert(tString, i2 % 2, target);
  }
}
