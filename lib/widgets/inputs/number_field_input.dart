import 'package:flutter/material.dart';

class NumberFieldInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFloat;

  const NumberFieldInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFloat,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      restorationId: null,
      scrollPadding: EdgeInsets.zero,
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.numberWithOptions(
        signed: true,
        decimal: isFloat,
      ),
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
            color: isFloat ? Colors.cyanAccent : Colors.blueAccent,
            width: 1,
          ),
        ),
      ),
    );
  }
}