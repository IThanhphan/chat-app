import 'package:flutter/material.dart';

class InputTextField extends StatefulWidget {
  final String text;
  final bool obscurePassword;
  final bool dark;
  final TextInputType inputType;
  final TextEditingController controller;
  final bool isDatePicker;

  const InputTextField({
    super.key,
    required this.text,
    required this.obscurePassword,
    required this.dark,
    required this.inputType,
    required this.controller,
    this.isDatePicker = false
  });

  @override
  State<InputTextField> createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  late bool _obscurePassword;

  @override
  void initState() {
    super.initState();
    _obscurePassword = widget.obscurePassword;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        widget.controller.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: widget.inputType,
      obscureText: _obscurePassword,
      controller: widget.controller,
      readOnly: widget.isDatePicker,
      onTap: widget.isDatePicker ? () => _selectDate(context) : null,
      style: TextStyle(color: widget.dark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        hintText: widget.text,
        hintStyle: TextStyle(
          color: widget.dark ? Colors.grey[400] : Colors.grey,
        ),
        suffixIcon:
            widget.obscurePassword
                ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: widget.dark ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
                : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00A8FF)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF00A8FF), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
