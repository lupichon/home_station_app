import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    Duration lookback = const Duration(days: 7),
    String resolution = '5 minutes',
  }) async {
    final end = DateTime.now().toUtc();
    final start = end.subtract(lookback);

    final query = '''
      query {
        device(deviceId:"$_deviceId") {
          history(
            fields:["$fieldKey"],
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

    final data = jsonDecode(response.body);

    if (data['errors'] != null) {
      throw Exception('Datacake GraphQL error: ${data['errors']}');
    }

    final historyRaw = data['data']['device']['history'];
    return _parse(historyRaw, fieldKey);
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}T'
      '${d.hour.toString().padLeft(2, '0')}:'
      '${d.minute.toString().padLeft(2, '0')}';

  List<HistoryPoint> _parse(dynamic raw, String fieldKey) {
    final list = jsonDecode(raw as String) as List;

    return list
        .where((p) => p[fieldKey] != null)
        .map((p) {
          final time = DateTime.parse(p['time'] as String).toLocal();
          final rawValue = p[fieldKey];

          double value;
          if (rawValue is bool) {
            value = rawValue ? 1.0 : 0.0;
          } else if (rawValue is num) {
            value = rawValue.toDouble();
          } else {
            throw Exception(
              'Type inattendu pour $fieldKey: ${rawValue.runtimeType} ($rawValue)',
            );
          }

          return HistoryPoint(time, value);
        })
        .toList();
  }
}