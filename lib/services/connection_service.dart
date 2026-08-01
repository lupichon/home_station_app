import 'dart:async';
import 'package:flutter/foundation.dart';

/// Interface que chaque transport doit implémenter.
abstract class ConnectionService {
  /// Flux de payloads décodés (clé → valeur brute).
  Stream<Map<String, dynamic>> get dataStream;

  bool get isConnected;
  String get statusMessage;

  VoidCallback? onConnectionChanged;

  Future<void> connect();
  Future<void> disconnect();
}