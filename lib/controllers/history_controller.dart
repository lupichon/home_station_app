import 'package:flutter/foundation.dart';
import '../models/history_model.dart';

class HistoryController extends ChangeNotifier {
  final String fieldKey;
  final DatacakeHistoryModel _model;

  Duration _lookback = const Duration(days: 1);
  late Future<List<HistoryPoint>> _points;

  HistoryController({required this.fieldKey, DatacakeHistoryModel? model})
      : _model = model ?? DatacakeHistoryModel() {
    _load();
  }

  Duration get lookback => _lookback;
  Future<List<HistoryPoint>> get points => _points;

  void setLookback(Duration d) {
    _lookback = d;
    _load();
    notifyListeners();
  }

  void _load() {
    _points = _model.fetchHistory(fieldKey: fieldKey, lookback: _lookback);
  }
}
