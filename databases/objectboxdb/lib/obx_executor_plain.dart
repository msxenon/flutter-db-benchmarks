import 'package:core/executer.dart';
import 'package:core/time_tracker.dart';
import 'package:objectboxdb/model.dart';

import 'objectbox.g.dart';

class ExecutorRelPlain
    extends ExecutorBaseRel<RelSourceEntityPlain, RelTargetEntity> {
  final Store store;
  final Box<RelSourceEntityPlain> box;
  final Query<RelSourceEntityPlain> query;
  final void Function(String, int, String) querySetParams;

  factory ExecutorRelPlain(Store store, TimeTracker tracker) {
    late final void Function(String, int, String) querySetParams;
    late final Query<RelSourceEntityPlain> queryT;
    final query = (store.box<RelSourceEntityPlain>().query(
            RelSourceEntityPlain_.tString.equals('') &
                RelSourceEntityPlain_.tLong.equals(0))
          ..link(RelSourceEntityPlain_.obxRelTarget,
              RelTargetEntity_.name.equals('')))
        .build();
    final queryParam1 = query.param(RelSourceEntityPlain_.tString);
    final queryParam2 = query.param(RelSourceEntityPlain_.tLong);
    final queryParam3 = query.param(RelTargetEntity_.name);
    querySetParams = (String sourceStringEquals, int sourceIntEquals,
        String targetStringEquals) {
      queryParam1.value = sourceStringEquals;
      queryParam2.value = sourceIntEquals;
      queryParam3.value = targetStringEquals;
    };
    queryT = query;

    return ExecutorRelPlain._(tracker, store, queryT, querySetParams);
  }

  ExecutorRelPlain._(
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
  Future<List<RelSourceEntityPlain>> queryWithLinks(
          List<ConfigQueryWithLinks> args) =>
      Future.value(tracker.track(
          'queryWithLinks',
          () => store.runInTransaction(TxMode.read, () {
                late List<RelSourceEntityPlain> result;
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
  RelSourceEntityPlain generateItem(String tString, int i2, target) {
    return RelSourceEntityPlain.forInsert(tString, i2 % 2, target);
  }
}
