import 'package:flutter/foundation.dart';
import 'dart:io';

/// Utility class for debugging purposes
class DebugUtils {
  /// Logs detailed information about a file
  static void logFileInfo(File file) {
    try {
      debugPrint('===== File Debug Info =====');
      debugPrint('File path: ${file.path}');
      debugPrint('File exists: ${file.existsSync()}');
      debugPrint('File size: ${file.lengthSync()} bytes');
      debugPrint('File last modified: ${file.lastModifiedSync()}');
      debugPrint('===========================');
    } catch (e) {
      debugPrint('Error getting file info: $e');
    }
  }

  /// Logs detailed error information
  static void logError(
    String operation,
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    debugPrint('===== ERROR =====');
    debugPrint('Operation: $operation');
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    debugPrint('================');
  }

  /// Logs Supabase operation details
  static void logSupabaseOperation(
    String operation, {
    String? objectId,
    Map<String, dynamic>? details,
  }) {
    debugPrint('===== SUPABASE OPERATION =====');
    debugPrint('Operation: $operation');
    if (objectId != null) {
      debugPrint('Object ID: $objectId');
    }
    if (details != null) {
      debugPrint('Details: $details');
    }
    debugPrint('============================');
  }
}
