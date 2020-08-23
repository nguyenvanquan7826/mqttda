import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:encrypt/encrypt.dart';

class AESHelper {
  Uint8List aesEncodeByte(Uint8List inputByte, String keyBase64, String ivBase64) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypted = getEncrypterCBC(key).encryptBytes(inputByte, iv: iv);
    return encrypted.bytes;
  }

  Uint8List aesEncodeByte64(String inputText, String keyBase64, String ivBase64) {
    Uint8List inputByte = Uint8List.fromList(inputText.codeUnits);
    return aesEncodeByte(inputByte, keyBase64, ivBase64);
  }

  Uint8List aesEncodeText(String inputText, String keyText, String ivText) {
    Uint8List inputByte = Uint8List.fromList(inputText.codeUnits);
    return aesEncodeByte(inputByte, base64.encode(keyText.codeUnits), base64.encode(ivText.codeUnits));
  }

  String aesDecodeByte(Uint8List inputByte, String keyBase64, String ivBase64) {
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final decrypted = getEncrypterCBC(key).decrypt(Encrypted(inputByte), iv: iv);
    return decrypted;
  }

  String aesDecodeText(Uint8List inputByte, String keyText, String ivText) {
    return aesDecodeByte(inputByte, base64.encode(keyText.codeUnits), base64.encode(ivText.codeUnits));
  }

  Encrypter getEncrypterCBC(encrypt.Key key) {
    return Encrypter(AES(key, mode: AESMode.cbc));
  }
}
