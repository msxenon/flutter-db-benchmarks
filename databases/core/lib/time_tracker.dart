class TimeTracker {
  /// list of runtimes indexed by function name
  final _times = <String, List<Duration>>{};
  final void Function(List<MapEntry<String, String>> args) outputFn;

  TimeTracker(this.outputFn);

  void clear() => _times.clear();

  void _saveTime(String fnName, Stopwatch watch) {
    watch.stop();

    _times[fnName] ??= <Duration>[];
    _times[fnName]!.add(watch.elapsed);
  }

  // whether the function is `async`
  bool _isAsync(dynamic Function() fn) => fn is Future Function();

  R track<R>(String fnName, R Function() fn) {
    if (_isAsync(fn)) {
      throw UnsupportedError("Use trackAsync() to track async functions.");
    }

    final watch = Stopwatch();

    watch.start();
    final result = fn();
    _saveTime(fnName, watch);
    return result;
  }

  Future<R> trackAsync<R>(String fnName, Future<R> Function() fn) async {
    if (!_isAsync(fn)) {
      throw UnsupportedError("Use track() to track synchronous functions.");
    }

    final watch = Stopwatch();

    watch.start();
    final result = await fn();
    _saveTime(fnName, watch);
    return result;
  }

  // void _print(List<dynamic> varArgs) =>
  //     outputFn(varArgs.map((e) => e.toString()).toList());
  void printTimes({List<String>? functions, bool avgOnly = false}) {
    functions ??= _times.keys.toList();

    // print the data as tab-separated a table
    final result = <MapEntry<String, String>>[];
    result.add(const MapEntry('Function', 'Average ms'));
    double totalAvg = 0;
    for (final fn in functions) {
      // Sub-millisecond values are within measurement error,
      // but show at least 1 decimal.
      final avg = averageMs(fn);
      totalAvg += avg;
      result.add(MapEntry(fn, avg.toStringAsFixed(1)));
    }
    result.add(MapEntry('All', totalAvg.toStringAsFixed(1)));

    outputFn(result);
    return;
  }
  // void printTimes({List<String>? functions, bool avgOnly = false}) {
  //   functions ??= _times.keys.toList();
  //
  //   // print the data as tab-separated a table
  //   _print(avgOnly
  //       ? ['Function', 'Average ms']
  //       : ['Function', 'Runs', 'Average ms', 'All times']);
  //
  //   for (final fn in functions) {
  //     // Sub-millisecond values are within measurement error,
  //     // but show at least 1 decimal.
  //     final avg = averageMs(fn).toStringAsFixed(1);
  //     if (avgOnly) {
  //       _print([fn, avg]);
  //     } else {
  //       final timesCols =
  //           _times[fn]?.map((d) => d.inMicroseconds.toDouble() / 1000) ?? [];
  //       _print([fn, _count(fn), avg, ...timesCols]);
  //     }
  //   }
  // }

  int _count(String fn) => _times[fn]?.length ?? 0;

  int _sum(String fn) =>
      _times[fn]?.map((d) => d.inMicroseconds).reduce((v, e) => v + e) ?? 0;

  double averageMs(String fn) =>
      _sum(fn).toDouble() / _count(fn).toDouble() / 1000;
}
