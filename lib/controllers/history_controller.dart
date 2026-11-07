import 'package:flutter/foundation.dart';
import '../models/history_model.dart';
import '../models/history_data_repository.dart';

class HistoryController extends ChangeNotifier {
  final String fieldKey;
  final HistoryDataRepository _repository;

  // null = fenêtre glissante des dernières 24 h
  DateTime? _customStart;
  DateTime? _customEnd;

  late DateTime _start;
  late DateTime _end;
  late Future<List<HistoryPoint>> _points;

  HistoryController({
    required this.fieldKey,
    HistoryDataRepository? repository,
  }) : _repository = repository ?? HistoryDataRepository() {
    _load();
  }

  bool get isDefaultRange => _customStart == null;
  DateTime get start => _start;
  DateTime get end => _end;
  Future<List<HistoryPoint>> get points => _points;

  void setRange(DateTime start, DateTime end) {
    _customStart = start;
    _customEnd = end;
    _load();
    notifyListeners();
  }

  void resetRange() {
    _customStart = null;
    _customEnd = null;
    _load();
    notifyListeners();
  }

  void _load() {
    final now = DateTime.now();
    if (_customStart == null) {
      _end = now;
      _start = now.subtract(const Duration(hours: 24));
    } else {
      _start = _customStart!;
      _end = _customEnd!.isAfter(now) ? now : _customEnd!;
    }
    _points = _repository.fetchHistory(
      fieldKey: fieldKey,
      start: _start,
      end: _end,
    );
  }
}
