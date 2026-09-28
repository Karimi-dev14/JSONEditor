import 'package:flutter/material.dart';
import '../models/editor_mode.dart';
import '../services/file_service.dart';
import '../services/notification_service.dart';
import '../widgets/json_tree_node.dart';

class JsonEditorScreen extends StatefulWidget {
  const JsonEditorScreen({super.key});

  @override
  State<JsonEditorScreen> createState() => _JsonEditorScreenState();
}

class _JsonEditorScreenState extends State<JsonEditorScreen> {
  dynamic _parsedJson;
  String? _currentFilePath;
  EditorMode _editorMode = EditorMode.valueEdit;

  Future<void> _handleImport() async {
    try {
      final result = await FileService.importJsonFile();
      if (result != null) {
        setState(() {
          _parsedJson = result['parsedJson'];
          _currentFilePath = result['path'];
        });

        if (mounted) {
          showModernNotification(
            context,
            messageFa: 'فایل JSON با موفقیت بارگذاری شد',
            messageEn: 'JSON file loaded successfully',
            type: NotificationType.success,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showModernNotification(
          context,
          messageFa: 'خطا در خواندن یا ساختار فایل JSON',
          messageEn: 'Error reading or parsing JSON file',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_parsedJson == null) return;

    if (_currentFilePath != null) {
      bool success = await FileService.saveJsonFile(_parsedJson, _currentFilePath!);
      if (mounted) {
        showModernNotification(
          context,
          messageFa: success ? 'تغییرات با موفقیت ذخیره شد' : 'خطا در ذخیره‌سازی فایل',
          messageEn: success ? 'Changes saved successfully' : 'Failed to overwrite file',
          type: success ? NotificationType.success : NotificationType.error,
        );
      }
    } else {
      _handleExport();
    }
  }

  Future<void> _handleExport() async {
    if (_parsedJson == null) return;

    String? path = await FileService.exportJsonFile(_parsedJson);
    if (path != null) {
      _currentFilePath = path;
      if (mounted) {
        showModernNotification(
          context,
          messageFa: 'فایل با موفقیت صادر شد',
          messageEn: 'File exported successfully',
          type: NotificationType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2D2D),
        elevation: 2,
        title: const Text('JSON Editor & Viewer', style: TextStyle(fontSize: 18)),
        actions: [
  
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SegmentedButton<EditorMode>(
              segments: const [
                ButtonSegment(
                  value: EditorMode.viewOnly,
                  label: Text('View Only', style: TextStyle(fontSize: 11)),
                  icon: Icon(Icons.visibility_outlined, size: 14),
                ),
                ButtonSegment(
                  value: EditorMode.valueEdit,
                  label: Text('Value Edit', style: TextStyle(fontSize: 11)),
                  icon: Icon(Icons.edit_note, size: 14),
                ),
                ButtonSegment(
                  value: EditorMode.fullEdit,
                  label: Text('Full Edit', style: TextStyle(fontSize: 11)),
                  icon: Icon(Icons.tune, size: 14),
                ),
              ],
              selected: {_editorMode},
              onSelectionChanged: (Set<EditorMode> newSelection) {
                setState(() {
                  _editorMode = newSelection.first;
                });
              },
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: _handleImport,
            icon: const Icon(Icons.file_open_outlined, size: 18),
            label: const Text('Open JSON'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: _parsedJson == null ? null : _handleSave,
            icon: const Icon(Icons.save_rounded, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: _parsedJson == null ? null : _handleExport,
            icon: const Icon(Icons.save_as_rounded, size: 18),
            label: const Text('Save As'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _parsedJson == null
          ? const Center(
              child: Text(
                'Please open a JSON file to start editing',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: const Color(0xFF252526),
                child: PageStorage(
                  bucket: PageStorageBucket(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12.0),
                    child: JsonTreeNode(
                      key: ValueKey('Root_${_currentFilePath ?? "temp"}'),
                      keyName: 'Root',
                      value: _parsedJson,
                      mode: _editorMode,
                      onUpdate: (newValue) {
                        setState(() {
                          _parsedJson = newValue;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}