import 'dart:async';
import 'package:flutter/foundation.dart';

/// Contrat que chaque transport doit implémenter.
abstract class ConnectionModel {
  /// Flux de payloads décodés (clé → valeur brute).
  Stream<Map<String, dynamic>> get dataStream;

  bool get isConnected;
  String get statusMessage;

  VoidCallback? onConnectionChanged;

  bool get supportsAlarm => false;

  Future<void> setAlarm(DateTime targetTime) =>
      throw UnsupportedError('Alarm is not supported by this connection');

  Future<void> cancelAlarm() =>
      throw UnsupportedError('Alarm is not supported by this connection');

  Future<void> connect();
  Future<void> disconnect();
}
