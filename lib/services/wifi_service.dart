import 'dart:async';
import 'package:flutter/foundation.dart';
import 'connection_service.dart';

/// Stub Wi-Fi — à implémenter.
class WifiService implements ConnectionService {
  final _controller = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get dataStream => _controller.stream;

  @override
  bool isConnected = false;

  @override
  String statusMessage = 'Not implemented';

  @override
  VoidCallback? onConnectionChanged;

  @override
  Future<void> connect() async {
    statusMessage = 'Wi-Fi not implemented yet';
  }

  @override
  Future<void> disconnect() async {
    isConnected = false;
    statusMessage = 'Disconnected';
  }

  void dispose() => _controller.close();
}