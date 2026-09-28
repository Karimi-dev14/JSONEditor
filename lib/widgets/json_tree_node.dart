import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:json_editor/models/editor_mode.dart';
import 'inputs/leaf_value_field.dart';
import 'type_badge.dart';

class JsonTreeNode extends StatelessWidget {
  final String keyName;
  final dynamic value;
  final EditorMode mode;
  final Function(dynamic newValue) onUpdate;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const JsonTreeNode({
    super.key,
    required this.keyName,
    required this.value,
    required this.mode,
    required this.onUpdate,
    this.onDelete,
    this.onDuplicate,
  });

  dynamic _deepCopy(dynamic item) {
    if (item == null) return null;
    return jsonDecode(jsonEncode(item));
  }

  void _handleComplexTypeChange(String newType) {
    switch (newType) {
      case 'String':
        onUpdate(value.toString());
        break;
      case 'Integer':
        onUpdate(0);
        break;
      case 'Float':
        onUpdate(0.0);
        break;
      case 'Boolean':
        onUpdate(false);
        break;
      case 'Null':
        onUpdate(null);
        break;
      case 'Dynamic':
        onUpdate(const JsonEncoder.withIndent('  ').convert(value));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic val = value;

    if (val is Map<String, dynamic>) {
      return ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const Icon(Icons.folder_open, color: Colors.orangeAccent, size: 20),
        title: Row(
          children: [
            Text(keyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 8),
            TypeBadge(
              type: 'Object',
              mode: mode,
              onTypeChanged: _handleComplexTypeChange,
            ),
            Text(' {${val.length}}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Spacer(),
            if (mode == EditorMode.fullEdit) ...[
              if (onDuplicate != null)
                IconButton(
                  icon: const Icon(Icons.control_point_duplicate_rounded, size: 18, color: Colors.blueAccent),
                  tooltip: 'Duplicate Object',
                  onPressed: onDuplicate,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  tooltip: 'Delete Object',
                  onPressed: onDelete,
                ),
            ],
          ],
        ),
        children: val.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: JsonTreeNode(
              keyName: entry.key,
              value: entry.value,
              mode: mode,
              onUpdate: (updatedChildValue) {
                val[entry.key] = updatedChildValue;
                onUpdate(val);
              },
              onDelete: () {
                val.remove(entry.key);
                onUpdate(val);
              },
              onDuplicate: () {
                String newKey = '${entry.key}_copy';
                int counter = 1;
                while (val.containsKey(newKey)) {
                  newKey = '${entry.key}_copy$counter';
                  counter++;
                }
                val[newKey] = _deepCopy(entry.value);
                onUpdate(val);
              },
            ),
          );
        }).toList(),
      );
    }

    if (val is List) {
      return ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: const Icon(Icons.data_array, color: Colors.purpleAccent, size: 20),
        title: Row(
          children: [
            Text(keyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 8),
            TypeBadge(
              type: 'Array',
              mode: mode,
              onTypeChanged: _handleComplexTypeChange,
            ),
            Text(' [${val.length}]', style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const Spacer(),
            if (mode == EditorMode.fullEdit) ...[
              if (onDuplicate != null)
                IconButton(
                  icon: const Icon(Icons.control_point_duplicate_rounded, size: 18, color: Colors.blueAccent),
                  tooltip: 'Duplicate Array',
                  onPressed: onDuplicate,
                ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                  tooltip: 'Delete Array',
                  onPressed: onDelete,
                ),
            ],
          ],
        ),
        children: List.generate(val.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: JsonTreeNode(
              keyName: '[$index]',
              value: val[index],
              mode: mode,
              onUpdate: (updatedChildValue) {
                val[index] = updatedChildValue;
                onUpdate(val);
              },
              onDelete: () {
                val.removeAt(index);
                onUpdate(val);
              },
              onDuplicate: () {
                val.insert(index + 1, _deepCopy(val[index]));
                onUpdate(val);
              },
            ),
          );
        }).toList(),
      );
    }

    return LeafValueField(
      keyName: keyName,
      value: val,
      mode: mode,
      onUpdate: onUpdate,
      onDelete: onDelete,
      onDuplicate: onDuplicate,
    );
  }
}