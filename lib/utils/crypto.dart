import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pointycastle/export.dart';

class Crypto {
  static const int keySize = 16;
  static const int ivSize  = 16;

  final Uint8List _key;

  Crypto._(this._key);

  factory Crypto.fromEnv() {
    return Crypto._(_parseHexKey(dotenv.env['AES_KEY'] ?? ''));
  }

  static Uint8List _parseHexKey(String hex) {
    final clean = hex.replaceAll(RegExp(r'[\s:]'), '');
    if (clean.length != keySize * 2) {
      throw FormatException(
          'AES_KEY doit contenir ${keySize * 2} caractères hexadécimaux '
          '(reçu ${clean.length})');
    }
    final key = Uint8List(keySize);
    for (int i = 0; i < keySize; i++) {
      key[i] = int.parse(clean.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return key;
  }

  /// Retourne les données en clair, ou null si la trame est trop courte.
  Uint8List? decrypt(List<int> frame) {
    if (frame.length <= ivSize) return null;

    final data    = Uint8List.fromList(frame);
    final counter = Uint8List.fromList(data.sublist(0, ivSize)); // IV = compteur initial
    final cipher  = data.sublist(ivSize);
    final output  = Uint8List(cipher.length);

    final aes = AESEngine()..init(true, KeyParameter(_key));
    final keystream = Uint8List(16);

    for (int offset = 0; offset < cipher.length; offset += 16) {
      aes.processBlock(counter, 0, keystream, 0);

      final n = min(16, cipher.length - offset);
      for (int j = 0; j < n; j++) {
        output[offset + j] = cipher[offset + j] ^ keystream[j];
      }

      // Incrémente le compteur de 16 octets en gros-boutiste (avec retenue)
      for (int k = 15; k >= 0; k--) {
        counter[k] = (counter[k] + 1) & 0xFF;
        if (counter[k] != 0) break;
      }
    }
    return output;
  }
}