import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadAssetImageAsBase64(String path) async {
  final byteData = await rootBundle.load(path);
  final bytes = byteData.buffer.asUint8List();
  return base64Encode(bytes);
}
