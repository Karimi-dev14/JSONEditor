import 'dart:convert';
import 'package:flutter/material.dart';

class DynamicJsonInput extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(dynamic parsedValue) onApplied;
  final TextDirection Function(String text) getDirectionality;

  const DynamicJsonInput({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onApplied,
    required this.getDirectionality,
  });

  @override
  State<DynamicJsonInput> createState() => _DynamicJsonInputState();
}

class _DynamicJsonInputState extends State<DynamicJsonInput> {
  String? _errorMessage;

  void _applyParsing() {
    String input = widget.controller.text.trim();
    if (input.isEmpty || input == 'null') {
      widget.onApplied(null);
      return;
    }

    if (input == 'true') {
      widget.onApplied(true);
      return;
    }

    if (input == 'false') {
      widget.onApplied(false);
      return;
    }

    if ((input.startsWith('{') && input.endsWith('}')) ||
        (input.startsWith('[') && input.endsWith(']'))) {
      try {
        dynamic parsed = jsonDecode(input);
        setState(() => _errorMessage = null);
        widget.onApplied(parsed);
        return;
      } catch (e) {
        setState(() => _errorMessage = 'Invalid JSON structure');
        return;
      }
    }

    int? intVal = int.tryParse(input);
    if (intVal != null) {
      widget.onApplied(intVal);
      return;
    }

    double? doubleVal = double.tryParse(input);
    if (doubleVal != null) {
      widget.onApplied(doubleVal);
      return;
    }

    widget.onApplied(input);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Directionality(
                textDirection: widget.getDirectionality(widget.controller.text),
                child: TextField(
                  restorationId: null,
                  scrollPadding: EdgeInsets.zero,
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  maxLines: null,
                  minLines: 2,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter JSON Object, Array, Bool, Number...',
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.tealAccent, width: 1),
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  _applyParsing();
                },
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.redAccent, fontSize: 11),
            ),
          ),
      ],
    );
  }
}