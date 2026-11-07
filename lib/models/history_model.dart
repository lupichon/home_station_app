import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'sensor_model.dart';

class HistoryPoint {
  final DateTime time;
  final double value;
  HistoryPoint(this.time, this.value);
}

class DatacakeHistoryModel {
  static final _apiToken = dotenv.env['DATACAKE_API_TOKEN']!;
  static final _deviceId = dotenv.env['DATACAKE_DEVICE_ID']!;
  static const _url = 'https://api.datacake.co/graphql/';

  Future<List<HistoryPoint>> fetchHistory({
    required String fieldKey,
    required DateTime start,
    required DateTime end,
  }) async {
    final historyFieldKey = _historyFieldKey(fieldKey);
    final raw = await _fetchRawHistory(
      fields: [historyFieldKey],
      start: start,
      end: end,
    );
    return parseHistory(raw, fieldKey, historyFieldKey);
  }

  Future<Map<String, List<HistoryPoint>>> fetchAllHistory({
    required DateTime start,
    required DateTime end,
  }) async {
    final sensorKeys = SensorsModel().all.map((sensor) => sensor.key).toList();
    final historyFields = sensorKeys.map(_historyFieldKey).toSet().toList();
    final raw = await _fetchRawHistory(
      fields: historyFields,
      start: start,
      end: end,
    );

    return {
      for (final key in sensorKeys)
        key: parseHistory(raw, key, _historyFieldKey(key)),
    };
  }

  String _historyFieldKey(String fieldKey) =>
      SensorKeys.flagMasks.containsKey(fieldKey) ? SensorKeys.flags : fieldKey;

  Future<String> _fetchRawHistory({
    required List<String> fields,
    required DateTime start,
    required DateTime end,
  }) async {
    final span = end.difference(start);
    final resolution = span <= const Duration(days: 7)
        ? '10 minutes'
        : span <= const Duration(days: 14)
            ? '1 hour'
            : '1 day';
    final query = '''
      query {
        device(deviceId:"$_deviceId") {
          history(
            fields:${jsonEncode(fields)},
            timerangestart:"${_fmt(start)}",
            timerangeend:"${_fmt(end)}",
            resolution:"$resolution"
          )
        }
      }
    ''';

    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Token $_apiToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode != 200) {
      throw Exception('Datacake HTTP ${response.statusCode}');
    }
    final data = jsonDecode(response.body);
    if (data['errors'] != null) {
      throw Exception('Datacake GraphQL error: ${data['errors']}');
    }

    final historyRaw = data['data']['device']['history'];
    if (historyRaw is! String) {
      throw Exception('Réponse historique Datacake invalide');
    }
    return historyRaw;
  }

  String _fmt(DateTime t) {
    final d = t.toUtc();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}T'
        '${d.hour.toString().padLeft(2, '0')}:'
        '${d.minute.toString().padLeft(2, '0')}';
  }

  @visibleForTesting
  static List<HistoryPoint> parseHistory(
    dynamic raw,
    String fieldKey,
    String historyFieldKey,
  ) {
    final list = jsonDecode(raw as String) as List;
    final flagMask = SensorKeys.flagMasks[fieldKey];

    return list
        .where((p) => p[historyFieldKey] != null)
        .map((p) {
          final time = DateTime.parse(p['time'] as String).toLocal();
          final rawValue = p[historyFieldKey];

          double value;
          if (flagMask != null && rawValue is bool) {
            value = rawValue ? 1.0 : 0.0;
          } else if (flagMask != null && rawValue is num) {
            value = (rawValue.toInt() & flagMask) != 0 ? 1.0 : 0.0;
          } else if (flagMask != null && rawValue is String) {
            final flagValue = int.tryParse(rawValue);
            if (flagValue == null) {
              throw Exception('Valeur FLAGS invalide: $rawValue');
            }
            value = (flagValue & flagMask) != 0 ? 1.0 : 0.0;
          } else if (rawValue is bool) {
            value = rawValue ? 1.0 : 0.0;
          } else if (rawValue is num) {
            value = rawValue.toDouble();
          } else {
            throw Exception(
              'Type inattendu pour $historyFieldKey: ${rawValue.runtimeType} ($rawValue)',
            );
          }

          return HistoryPoint(time, value);
        })
        .toList();
  }
}