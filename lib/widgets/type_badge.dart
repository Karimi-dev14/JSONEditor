import 'package:flutter/material.dart';
import '../models/editor_mode.dart';

class TypeBadge extends StatelessWidget {
  final String type;
  final EditorMode mode;
  final ValueChanged<String>? onTypeChanged;

  const TypeBadge({
    super.key,
    required this.type,
    required this.mode,
    this.onTypeChanged,
  });

  Color _getBadgeColor(String typeStr) {
    switch (typeStr) {
      case 'Object':
        return Colors.orangeAccent;
      case 'Array':
        return Colors.purpleAccent;
      case 'String':
        return Colors.greenAccent;
      case 'Integer':
        return Colors.blueAccent;
      case 'Float':
        return Colors.cyanAccent;
      case 'Boolean':
        return Colors.amberAccent;
      case 'Null':
        return Colors.redAccent;
      case 'Dynamic':
        return Colors.tealAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getBadgeColor(type);

    if (mode == EditorMode.fullEdit && onTypeChanged != null && type != 'Object' && type != 'Array') {
      return PopupMenuButton<String>(
        tooltip: 'تغییر نوع داده',
        onSelected: onTypeChanged,
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'String', child: Text('String')),
          PopupMenuItem(value: 'Integer', child: Text('Integer')),
          PopupMenuItem(value: 'Float', child: Text('Float')),
          PopupMenuItem(value: 'Boolean', child: Text('Boolean')),
          PopupMenuItem(value: 'Null', child: Text('Null')),
          PopupMenuItem(value: 'Dynamic', child: Text('Dynamic Input (پویا)')),
        ],
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            border: Border.all(color: color, width: 1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                type,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 2),
              Icon(Icons.arrow_drop_down, color: color, size: 14),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color, width: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}