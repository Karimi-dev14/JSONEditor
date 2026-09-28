import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class FileService {
  /// انتخاب و باز کردن فایل JSON
  static Future<Map<String, dynamic>?> importJsonFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null) {
      String content;
      String? path = result.files.single.path;

      if (path != null) {
        content = await File(path).readAsString();
      } else if (result.files.single.bytes != null) {
        content = utf8.decode(result.files.single.bytes!);
      } else {
        return null;
      }

      dynamic parsedData = jsonDecode(content);
      return {
        'parsedJson': parsedData,
        'path': path,
      };
    }
    return null;
  }

  /// ذخیره مستقیم روی همان فایل اولیه‌
  static Future<bool> saveJsonFile(dynamic jsonData, String path) async {
    try {
      String jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await File(path).writeAsString(jsonString);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// ذخیره فایل در یک مسیر جدید (Export)
  static Future<String?> exportJsonFile(dynamic jsonData) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save JSON File As',
      fileName: 'edited_data.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (outputFile != null) {
      String jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await File(outputFile).writeAsString(jsonString);
      return outputFile;
    }
    return null;
  }
}