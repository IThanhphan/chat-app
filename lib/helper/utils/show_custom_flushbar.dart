import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showCustomFlushbar({
  required BuildContext context,
  required String text,
  required dynamic color,
  required IconData icon,
}) {
  Flushbar(
    message: text,
    duration: const Duration(seconds: 2),
    flushbarPosition: FlushbarPosition.TOP,
    backgroundColor: color,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    icon: Icon(icon, color: Colors.white),
  ).show(context);
}
