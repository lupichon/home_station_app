import 'package:flutter/foundation.dart';
import 'history_archive_database.dart';
import 'history_model.dart';

class HistoryDataRepository {
  static const _retention = Duration(days: 7);

  final DatacakeHistoryModel _remote;
  final HistoryArchiveDatabase _archive;

  HistoryDataRepository({
    DatacakeHistoryModel? remote,
    HistoryArchiveDatabase? archive,
  })  : _remote = remote ?? DatacakeHistoryModel(),
        _archive = archive ?? HistoryArchiveDatabase();

  Future<void> archiveRecentHistory() async {
    final end = DateTime.now();
    final start = end.subtract(_retention);
    final histories = await _remote.fetchAllHistory(start: start, end: end);
    await _archive.upsert(histories);
  }

  Future<List<HistoryPoint>> fetchHistory({
    required String fieldKey,
    required DateTime start,
    required DateTime end,
  }) async {
    var archived = <HistoryPoint>[];
    try {
      archived = await _archive.readRange(
        fieldKey: fieldKey,
        start: start,
        end: end,
      );
    } catch (error) {
      debugPrint('History archive read failed: $error');
    }

    final cutoff = DateTime.now().subtract(_retention);
    if (!end.isAfter(cutoff)) return archived;

    final remoteStart = start.isAfter(cutoff) ? start : cutoff;
    List<HistoryPoint> recent;
    try {
      recent = await _remote.fetchHistory(
        fieldKey: fieldKey,
        start: remoteStart,
        end: end,
      );
    } catch (error) {
      if (archived.isEmpty) rethrow;
      debugPrint('Recent Datacake history unavailable; using local archive: $error');
      recent = const [];
    }

    final pointsByTimestamp = <int, HistoryPoint>{
      for (final point in archived)
        point.time.toUtc().millisecondsSinceEpoch: point,
      for (final point in recent)
        point.time.toUtc().millisecondsSinceEpoch: point,
    };
    final points = pointsByTimestamp.values.toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return points;
  }
}