import 'package:flutter/material.dart';
import 'package:json_editor/models/editor_mode.dart';
import 'package:json_editor/widgets/type_badge.dart';
import 'custom_bool_selector.dart';
import 'dynamic_json_input.dart';
import 'number_field_input.dart';

class LeafValueField extends StatefulWidget {
  final String keyName;
  final dynamic value;
  final EditorMode mode;
  final Function(dynamic newValue) onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const LeafValueField({
    super.key,
    required this.keyName,
    required this.value,
    required this.mode,
    required this.onUpdate,
    this.onDelete,
    this.onDuplicate,
  });

  @override
  State<LeafValueField> createState() => _LeafValueFieldState();
}

class _LeafValueFieldState extends State<LeafValueField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isDynamicMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_isDynamicMode) {
      _applyNumberValidationOnBlur();
    }
  }

  @override
  void didUpdateWidget(covariant LeafValueField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      String text = widget.value?.toString() ?? '';
      if (_controller.text != text) {
        _controller.text = text;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  TextDirection _getDirectionality(String text) {
    if (text.isEmpty) return TextDirection.ltr;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return TextDirection.ltr;
    final firstChar = trimmed.codeUnitAt(0);
    if ((firstChar >= 0x0600 && firstChar <= 0x06FF) ||
        (firstChar >= 0x0750 && firstChar <= 0x077F) ||
        (firstChar >= 0xFB50 && firstChar <= 0xFDFF) ||
        (firstChar >= 0xFE70 && firstChar <= 0xFEFF)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  String _getJsonType(dynamic val) {
    if (_isDynamicMode) return 'Dynamic';
    if (val == null) return 'Null';
    if (val is bool) return 'Boolean';
    if (val is int) return 'Integer';
    if (val is double) return 'Float';
    if (val is num) return val.toString().contains('.') ? 'Float' : 'Integer';
    return 'String';
  }

  void _handleTypeChange(String newType) {
    if (newType == 'Dynamic') {
      setState(() => _isDynamicMode = true);
      return;
    }

    _isDynamicMode = false;

    switch (newType) {
      case 'String':
        widget.onUpdate(widget.value?.toString() ?? '');
        break;
      case 'Integer':
        int? val = int.tryParse(widget.value?.toString() ?? '');
        widget.onUpdate(val ?? 0);
        break;
      case 'Float':
        double? val = double.tryParse(widget.value?.toString() ?? '');
        widget.onUpdate(val ?? 0.0);
        break;
      case 'Boolean':
        bool val = widget.value.toString().toLowerCase() == 'true';
        widget.onUpdate(val);
        break;
      case 'Null':
        widget.onUpdate(null);
        break;
    }
  }

  void _applyNumberValidationOnBlur() {
    dynamic val = widget.value;
    String typeLabel = _getJsonType(val);
    String input = _controller.text.trim();

    if (typeLabel == 'Integer') {
      int? parsedInt = int.tryParse(input);
      if (parsedInt != null) {
        widget.onUpdate(parsedInt);
      } else {
        _controller.text = val?.toString() ?? '0';
      }
    } else if (typeLabel == 'Float') {
      double? parsedDouble = double.tryParse(input);
      if (parsedDouble != null) {
        widget.onUpdate(parsedDouble);
      } else {
        _controller.text = val?.toString() ?? '0.0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic val = widget.value;
    String typeLabel = _getJsonType(val);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.label_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              '${widget.keyName}:',
              style: const TextStyle(fontSize: 13, color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TypeBadge(
            type: typeLabel,
            mode: widget.mode,
            onTypeChanged: _handleTypeChange,
          ),
          const SizedBox(width: 10),
          Expanded(child: _buildInputWidget(typeLabel, val)),
          if (widget.mode == EditorMode.fullEdit) ...[
            if (widget.onDuplicate != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.control_point_duplicate_rounded, size: 18, color: Colors.blueAccent),
                tooltip: 'Duplicate item',
                onPressed: widget.onDuplicate,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
            if (widget.onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                tooltip: 'Delete item',
                onPressed: widget.onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInputWidget(String typeLabel, dynamic val) {
    if (widget.mode == EditorMode.viewOnly) {
      String displayStr = val?.toString() ?? 'null';
      return Directionality(
        textDirection: _getDirectionality(displayStr),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            displayStr,
            style: TextStyle(
              fontSize: 13,
              color: val == null ? Colors.redAccent.shade100 : Colors.white60,
              fontStyle: val == null ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      );
    }

    if (_isDynamicMode) {
      return DynamicJsonInput(
        controller: _controller,
        focusNode: _focusNode,
        getDirectionality: _getDirectionality,
        onApplied: (parsedValue) {
          setState(() => _isDynamicMode = false);
          widget.onUpdate(parsedValue);
        },
      );
    }

    if (typeLabel == 'Boolean') {
      return Align(
        alignment: Alignment.centerLeft,
        child: CustomBoolSelector(
          value: (val == true),
          onChanged: (newValue) => widget.onUpdate(newValue),
        ),
      );
    }

    if (typeLabel == 'Null') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Text(
          'null',
          style: TextStyle(fontSize: 13, color: Colors.redAccent, fontStyle: FontStyle.italic),
        ),
      );
    }

    if (typeLabel == 'Integer' || typeLabel == 'Float') {
      return NumberFieldInput(
        controller: _controller,
        focusNode: _focusNode,
        isFloat: typeLabel == 'Float',
      );
    }

    return Directionality(
      textDirection: _getDirectionality(_controller.text),
      child: TextField(
        restorationId: null,
        scrollPadding: EdgeInsets.zero,
        controller: _controller,
        maxLines: null,
        minLines: 1,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.greenAccent, width: 1),
          ),
        ),
        onChanged: (text) {
          setState(() {});
          widget.onUpdate(text);
        },
      ),
    );
  }
}