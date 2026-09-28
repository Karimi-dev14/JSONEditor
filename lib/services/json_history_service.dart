import 'dart:convert';

class JsonHistoryService {
  final int maxHistoryLength;
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  JsonHistoryService({this.maxHistoryLength = 10});

  bool get canUndo => _undoStack.length > 1;
  bool get canRedo => _redoStack.isNotEmpty;


  void initialize(dynamic initialData) {
    _undoStack.clear();
    _redoStack.clear();
    if (initialData != null) {
      _undoStack.add(jsonEncode(initialData));
    }
  }


  void pushState(dynamic newData) {
    if (newData == null) return;
    String encoded = jsonEncode(newData);


    if (_undoStack.isNotEmpty && _undoStack.last == encoded) {
      return;
    }

    _undoStack.add(encoded);
    _redoStack.clear(); 

    if (_undoStack.length > maxHistoryLength) {
      _undoStack.removeAt(0);
    }
  }


  dynamic undo() {
    if (!canUndo) return null;

    String currentState = _undoStack.removeLast();
    _redoStack.add(currentState);

    return jsonDecode(_undoStack.last);
  }


  dynamic redo() {
    if (!canRedo) return null;

    String nextState = _redoStack.removeLast();
    _undoStack.add(nextState);

    return jsonDecode(nextState);
  }


  void clear() {
    _undoStack.clear();
    _redoStack.clear();
  }
}