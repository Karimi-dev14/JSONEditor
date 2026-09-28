import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/editor_mode.dart';
import '../services/file_service.dart';
import '../services/json_history_service.dart';
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

  final FocusNode _mainFocusNode = FocusNode();

  final JsonHistoryService _historyService = JsonHistoryService(
    maxHistoryLength: 10,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mainFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _mainFocusNode.dispose();
    super.dispose();
  }

  void _updateJsonState(dynamic newJson, {bool recordHistory = true}) {
    setState(() {
      _parsedJson = newJson;
    });
    if (recordHistory) {
      _historyService.pushState(newJson);
    }
  }

  void _handleUndo() {
    if (!_historyService.canUndo) return;
    dynamic previousState = _historyService.undo();
    if (previousState != null) {
      _updateJsonState(previousState, recordHistory: false);
      // showModernNotification(
      //   context,
      //   messageFa: 'Undo applied',
      //   messageEn: 'Undo applied',
      //   type: NotificationType.info,
      // );
    }
  }

  void _handleRedo() {
    if (!_historyService.canRedo) return;
    dynamic nextState = _historyService.redo();
    if (nextState != null) {
      _updateJsonState(nextState, recordHistory: false);
      // showModernNotification(
      //   context,
      //   messageFa: 'Redo applied',
      //   messageEn: 'Redo applied',
      //   type: NotificationType.info,
      // );
    }
  }

  Future<void> _handleImport() async {
    try {
      final result = await FileService.importJsonFile();
      if (result != null) {
        dynamic importedJson = result['parsedJson'];
        setState(() {
          _parsedJson = importedJson;
          _currentFilePath = result['path'];
        });

        _historyService.initialize(importedJson);
        _mainFocusNode.requestFocus();

        if (mounted) {
          showModernNotification(
            context,
            messageFa: 'JSON file loaded successfully',
            messageEn: 'JSON file loaded successfully',
            type: NotificationType.success,
          );
        }
      }
    } catch (_) {
      if (mounted) {
        showModernNotification(
          context,
          messageFa: 'Error reading or parsing JSON file',
          messageEn: 'Error reading or parsing JSON file',
          type: NotificationType.error,
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (_parsedJson == null) return;

    if (_currentFilePath != null) {
      bool success = await FileService.saveJsonFile(
        _parsedJson,
        _currentFilePath!,
      );
      if (mounted) {
        showModernNotification(
          context,
          messageFa: success
              ? 'Changes saved successfully'
              : 'Failed to overwrite file',
          messageEn: success
              ? 'Changes saved successfully'
              : 'Failed to overwrite file',
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
          messageFa: 'File exported successfully',
          messageEn: 'File exported successfully',
          type: NotificationType.success,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Undo: Ctrl+Z
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
            _handleUndo,
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _handleUndo,

        // Redo: Ctrl+Y
        const SingleActivator(LogicalKeyboardKey.keyY, control: true):
            _handleRedo,
        const SingleActivator(LogicalKeyboardKey.keyY, meta: true): _handleRedo,
        const SingleActivator(
          LogicalKeyboardKey.keyZ,
          control: true,
          shift: true,
        ): _handleRedo,

        // Save: Ctrl+S
        const SingleActivator(LogicalKeyboardKey.keyS, control: true):
            _handleSave,
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): _handleSave,
      },
      child: Focus(
        focusNode: _mainFocusNode,
        autofocus: true,
        child: GestureDetector(
          onTap: () {
            _mainFocusNode.requestFocus();
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xFF2D2D2D),
              elevation: 2,
              title: const Text('JSON Editor', style: TextStyle(fontSize: 18)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  tooltip: 'Ctrl+Z',
                  onPressed: _historyService.canUndo ? _handleUndo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo_rounded),
                  tooltip: 'Ctrl+Y',
                  onPressed: _historyService.canRedo ? _handleRedo : null,
                ),
                const VerticalDivider(
                  indent: 12,
                  endIndent: 12,
                  color: Colors.white24,
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    // color: const Color.fromARGB(0, 226, 119, 119),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SegmentedButton<EditorMode>(
                    segments: const [
                      ButtonSegment(
                        value: EditorMode.viewOnly,
                        label: Text(
                          'View Only',
                          style: TextStyle(fontSize: 11),
                        ),
                        icon: Icon(Icons.visibility_outlined, size: 14),
                      ),
                      ButtonSegment(
                        value: EditorMode.valueEdit,
                        label: Text(
                          'Value Edit',
                          style: TextStyle(fontSize: 11),
                        ),
                        icon: Icon(Icons.edit_note, size: 14),
                      ),
                      ButtonSegment(
                        value: EditorMode.fullEdit,
                        label: Text(
                          'Full Edit',
                          style: TextStyle(fontSize: 11),
                        ),
                        icon: Icon(Icons.tune, size: 14),
                      ),
                    ],
                    selected: {_editorMode},
                    onSelectionChanged: (Set<EditorMode> newSelection) {
                      setState(() {
                        _editorMode = newSelection.first;
                      });
                      _mainFocusNode.requestFocus();
                    },
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 51, 101, 121),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _handleImport,
                  icon: const Icon(Icons.file_open_outlined, size: 18),
                  label: const Text('Open JSON'),
                ),

                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 76, 107, 175),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _parsedJson == null ? null : _handleExport,
                  icon: const Icon(Icons.save_as_rounded, size: 18),
                  label: const Text('Save As'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 0, 131, 76),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _parsedJson == null ? null : _handleSave,
                  icon: const Icon(Icons.save_rounded, size: 18),
                  label: const Text('Save'),
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
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12.0),
                        child: JsonTreeNode(
                          keyName: 'Root',
                          value: _parsedJson,
                          mode: _editorMode,
                          onUpdate: (newValue) {
                            _updateJsonState(newValue);
                          },
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
