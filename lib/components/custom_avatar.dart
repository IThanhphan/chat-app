import 'dart:convert';
import 'package:flutter/material.dart';

class CustomAvatar extends StatelessWidget {
  final String imageBase64;
  final double radius;

  const CustomAvatar({
    super.key,
    required this.imageBase64,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage:
          imageBase64 != ''
              ? MemoryImage(base64Decode(imageBase64))
              : const AssetImage('assets/logo.png') as ImageProvider,
    );
  }
}
