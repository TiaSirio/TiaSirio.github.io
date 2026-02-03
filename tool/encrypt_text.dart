import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

void main() {
  final pass = 'a garibaldi alle 8';
  final titleText = 'Bisogna riprendere! Buon compleanno <3';
  final secretContent = 'Codice: 123';

  final bytes = utf8.encode(pass.toLowerCase().trim());
  final digest = sha256.convert(bytes);
  final key = encrypt.Key(Uint8List.fromList(digest.bytes));
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final iv1 = encrypt.IV.fromLength(16);
  final encryptedTitle = '${iv1.base64}:${encrypter.encrypt(titleText, iv: iv1).base64}';

  final iv2 = encrypt.IV.fromLength(16);
  final encryptedCode = '${iv2.base64}:${encrypter.encrypt(secretContent, iv: iv2).base64}';

  final data = {
    'title': encryptedTitle,
    'code': encryptedCode,
  };

  final jsonString = JsonEncoder.withIndent('  ').convert(data);
  
  final file = File('assets/secrets/secrets.json');
  file.writeAsStringSync(jsonString);

  print('File assets/secrets.json generato con successo!');
  print('Password impostata: $pass');
  print('Titolo: $titleText');
  print('Segreto: $secretContent');
}