enum ConnectionType {
  lora('LoRa / MQTT', 'lora'),
  ble('Bluetooth BLE', 'ble'),
  wifi('Wi-Fi', 'wifi');

  final String label;
  final String key;
  const ConnectionType(this.label, this.key);
}