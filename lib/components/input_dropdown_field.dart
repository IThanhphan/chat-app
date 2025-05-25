import 'package:flutter/material.dart';

class InputDropdownField extends StatelessWidget {
  final String hint;
  final bool dark;
  final bool? selectedValue; // ✅ Giá trị là bool (true/false)
  final ValueChanged<bool?> onChanged;

  const InputDropdownField({
    super.key,
    required this.hint,
    required this.dark,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<bool>(
      value: selectedValue,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: dark ? Colors.grey[400] : Colors.grey,
        ),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00A8FF)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00A8FF), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dropdownColor: dark ? Colors.grey[900] : Colors.white,
      style: TextStyle(
        color: dark ? Colors.white : Colors.black,
      ),
      items: const [
        DropdownMenuItem<bool>(
          value: true,
          child: Text("Nam"),
        ),
        DropdownMenuItem<bool>(
          value: false,
          child: Text("Nữ"),
        ),
      ],
    );
  }
}
