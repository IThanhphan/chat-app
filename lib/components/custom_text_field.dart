import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool dark;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.dark,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        style: TextStyle(color: dark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: dark ? Colors.white70 : Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          isDense: true,
        ),
      ),
    );
  }
}
