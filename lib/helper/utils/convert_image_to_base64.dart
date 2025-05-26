import 'dart:convert';
import 'dart:io';

Future<String?> convertImageToBase64(File imageFile) async {
  try {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  } catch (e) {
    print('Error converting image to base64: $e');
    return null;
  }
}
