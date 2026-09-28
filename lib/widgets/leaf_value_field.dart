import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/editor_mode.dart';
import 'type_badge.dart';

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
  String? _dynamicError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (_isDynamicMode) {
        _applyDynamicParsing();
      } else {
        _applyNumberValidationOnBlur();
      }
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
    setState(() {
      _dynamicError = null;
    });

    if (newType == 'Dynamic') {
      setState(() {
        _isDynamicMode = true;
      });
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

  void _applyDynamicParsing() {
    String input = _controller.text.trim();
    if (input.isEmpty || input == 'null') {
      _isDynamicMode = false;
      widget.onUpdate(null);
      return;
    }

    if (input == 'true') {
      _isDynamicMode = false;
      widget.onUpdate(true);
      return;
    }

    if (input == 'false') {
      _isDynamicMode = false;
      widget.onUpdate(false);
      return;
    }

    if ((input.startsWith('{') && input.endsWith('}')) ||
        (input.startsWith('[') && input.endsWith(']'))) {
      try {
        dynamic parsed = jsonDecode(input);
        setState(() {
          _dynamicError = null;
          _isDynamicMode = false;
        });
        widget.onUpdate(parsed);
        return;
      } catch (e) {
        setState(() {
          _dynamicError = 'Invalid JSON structure';
        });
        return;
      }
    }

    int? intVal = int.tryParse(input);
    if (intVal != null) {
      _isDynamicMode = false;
      widget.onUpdate(intVal);
      return;
    }

    double? doubleVal = double.tryParse(input);
    if (doubleVal != null) {
      _isDynamicMode = false;
      widget.onUpdate(doubleVal);
      return;
    }

    _isDynamicMode = false;
    widget.onUpdate(input);
  }

  @override
  Widget build(BuildContext context) {
    dynamic val = widget.value;
    String typeLabel = _getJsonType(val);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
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
                    icon: const Icon(
                      Icons.control_point_duplicate_rounded,
                      size: 18,
                      color: Colors.blueAccent,
                    ),
                    tooltip: 'Duplicate item',
                    onPressed: widget.onDuplicate,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
                if (widget.onDelete != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Delete item',
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                  ),
                ],
              ],
            ],
          ),
          if (_dynamicError != null)
            Padding(
              padding: const EdgeInsets.only(left: 140, top: 2),
              child: Text(
                _dynamicError!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 11),
              ),
            ),
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
      return Row(
        children: [
          Expanded(
            child: Directionality(
              textDirection: _getDirectionality(_controller.text),
              child: TextField(
                key: ValueKey(
                  'input_dyn_${widget.mode.name}_${widget.keyName}',
                ),
                restorationId: null,
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Enter JSON Object, Array, Bool, Number...',
                  hintStyle: const TextStyle(
                    color: Colors.white30,
                    fontSize: 11,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Colors.tealAccent,
                      width: 1,
                    ),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              FocusScope.of(context).unfocus();
              _applyDynamicParsing();
            },
            child: const Icon(Icons.check, size: 16, color: Colors.white),
          ),
        ],
      );
    }

    if (typeLabel == 'Boolean') {
      bool boolValue = (val == true);
      return Align(
        alignment: Alignment.centerLeft,
        child: ToggleButtons(
          key: ValueKey(
            'toggle_bool_${widget.mode.name}_${widget.keyName}_$boolValue',
          ),
          constraints: const BoxConstraints(minWidth: 50, minHeight: 30),
          borderRadius: BorderRadius.circular(6),
          selectedColor: Colors.black,
          fillColor: boolValue ? Colors.amberAccent : Colors.redAccent.shade100,
          color: Colors.white70,
          isSelected: <bool>[boolValue == true, boolValue == false],
          onPressed: (int index) {
            bool newValue = (index == 0);
            widget.onUpdate(newValue);
          },
          children: const <Widget>[
            Text(
              'true',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
            Text(
              'false',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
            ),
          ],
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
          style: TextStyle(
            fontSize: 13,
            color: Colors.redAccent,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    if (typeLabel == 'Integer' || typeLabel == 'Float') {
      return TextField(
        key: ValueKey(
          'input_num_${widget.mode.name}_${typeLabel}_${widget.keyName}',
        ),
        restorationId: null,
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.numberWithOptions(
          signed: true,
          decimal: typeLabel == 'Float',
        ),
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(
              color: typeLabel == 'Float'
                  ? Colors.cyanAccent
                  : Colors.blueAccent,
              width: 1,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: _getDirectionality(_controller.text),
      child: TextField(
        key: ValueKey('input_str_${widget.mode.name}_${widget.keyName}'),
        restorationId: null,
        controller: _controller,
        maxLines: null,
        minLines: 1,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide.none,
          ),
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
