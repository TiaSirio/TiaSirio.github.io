import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionUtils {
  /// Encrypts a [text] using [password] as the key.
  static String encryptText(String text, String password) {
    final key = _deriveKey(password);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final encrypted = encrypter.encrypt(text, iv: iv);
    // Return IV + Encrypted data as base64
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Decrypts a [base64Text] using [password] as the key.
  /// Returns null if decryption fails.
  static String? decryptText(String base64Text, String password) {
    try {
      final parts = base64Text.split(':');
      if (parts.length != 2) return null;

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedData = encrypt.Encrypted.fromBase64(parts[1]);
      
      final key = _deriveKey(password);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));

      return encrypter.decrypt(encryptedData, iv: iv);
    } catch (e) {
      return null;
    }
  }

  static encrypt.Key _deriveKey(String password) {
    // Hash the password to get a 32-byte key
    final bytes = utf8.encode(password.toLowerCase().trim());
    final digest = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }
}
