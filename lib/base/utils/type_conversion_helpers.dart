/// Global Type Conversion Helpers
/// 
/// This file contains utility functions for safe type conversions
/// across the application. All conversions are null-safe and handle
/// multiple input types.
///
/// Usage:
/// ```dart
/// import '../../base/utils/type_conversion_helpers.dart';
/// 
/// double? value = toDouble("25.5");
/// int? count = toInt("3");
/// bool? flag = toBool("true");
/// String text = toString(123);
/// ```

/// Convert any value to [double]
/// 
/// Safely converts String, int, double, or null to double?
/// 
/// Handles:
/// - double: returns as-is
/// - int: converts to double
/// - String: parses to double
/// - null: returns null
/// - invalid String: logs error and returns null
/// 
/// Example:
/// ```dart
/// toDouble(25)        // → 25.0
/// toDouble("25.5")    // → 25.5
/// toDouble(null)      // → null
/// toDouble("abc")     // → null (with error log)
/// ```
double? toDouble(dynamic value, {String? fieldName}) {
  if (value == null) return null;

  if (value is double) {
    return value;
  }

  if (value is int) {
    return value.toDouble();
  }

  if (value is String) {
    if (value.isEmpty) return null;
    try {
      return double.parse(value);
    } catch (e) {
      _logConversionError('double', value, fieldName, e);
      return null;
    }
  }

  _logTypeError('double', value.runtimeType, fieldName);
  return null;
}

/// Convert any value to [int]
/// 
/// Safely converts String, int, double, or null to int?
/// 
/// Handles:
/// - int: returns as-is
/// - double: converts to int (truncates)
/// - String: parses to int
/// - null: returns null
/// - invalid String: logs error and returns null
/// 
/// Example:
/// ```dart
/// toInt(25)       // → 25
/// toInt("25")     // → 25
/// toInt(25.5)     // → 25 (truncated)
/// toInt(null)     // → null
/// toInt("abc")    // → null (with error log)
/// ```
int? toInt(dynamic value, {String? fieldName}) {
  if (value == null) return null;

  if (value is int) {
    return value;
  }

  if (value is double) {
    return value.toInt();
  }

  if (value is String) {
    if (value.isEmpty) return null;
    try {
      return int.parse(value);
    } catch (e) {
      _logConversionError('int', value, fieldName, e);
      return null;
    }
  }

  _logTypeError('int', value.runtimeType, fieldName);
  return null;
}

/// Convert any value to [String]
/// 
/// Safely converts any value to String
/// 
/// Handles:
/// - String: returns as-is
/// - null: returns 'null' or provided defaultValue
/// - any other: uses toString()
/// 
/// Example:
/// ```dart
/// toString(123)           // → "123"
/// toString("hello")       // → "hello"
/// toString(null)          // → "null"
/// toString(null, "N/A")   // → "N/A"
/// ```
String toString(dynamic value, {String defaultValue = 'null'}) {
  if (value == null) return defaultValue;
  return value.toString();
}

/// Convert any value to [bool]
/// 
/// Safely converts String, bool, int, or null to bool?
/// 
/// String values:
/// - "true", "1", "yes", "on": true
/// - "false", "0", "no", "off": false
/// - other: returns null
/// 
/// Handles:
/// - bool: returns as-is
/// - int: 1 → true, 0 → false, other → null
/// - String: parses common boolean strings
/// - null: returns null
/// 
/// Example:
/// ```dart
/// toBool(true)        // → true
/// toBool(false)       // → false
/// toBool(1)           // → true
/// toBool(0)           // → false
/// toBool("true")      // → true
/// toBool("yes")       // → true
/// toBool("false")     // → false
/// toBool("no")        // → false
/// toBool(null)        // → null
/// toBool("invalid")   // → null
/// ```
bool? toBool(dynamic value, {String? fieldName}) {
  if (value == null) return null;

  if (value is bool) {
    return value;
  }

  if (value is int) {
    if (value == 1) return true;
    if (value == 0) return false;
    print('[TYPE_CONVERSION_ERROR] Invalid int value for bool'
        '${fieldName != null ? ' (field: $fieldName)' : ''}: '
        'expected 0 or 1, got $value');
    return null;
  }

  if (value is String) {
    final lowerValue = value.toLowerCase().trim();
    if (['true', '1', 'yes', 'on'].contains(lowerValue)) return true;
    if (['false', '0', 'no', 'off'].contains(lowerValue)) return false;
    print('[TYPE_CONVERSION_ERROR] Invalid string value for bool'
        '${fieldName != null ? ' (field: $fieldName)' : ''}: '
        'expected true/false/yes/no, got $lowerValue');
    return null;
  }

  _logTypeError('bool', value.runtimeType, fieldName);
  return null;
}

/// Convert any value to [List<T>]
/// 
/// Safely converts any value to List or returns empty list
/// 
/// Handles:
/// - List: returns as-is (casted)
/// - null: returns empty list
/// - other: wraps in list
/// 
/// Example:
/// ```dart
/// toList([1, 2, 3])      // → [1, 2, 3]
/// toList(null)           // → []
/// toList("test")         // → ["test"]
/// ```
List<T> toList<T>(dynamic value, {String? fieldName}) {
  if (value == null) return [];

  if (value is List) {
    try {
      return List<T>.from(value);
    } catch (e) {
      _logConversionError('List<$T>', value, fieldName, e);
      return [];
    }
  }

  return [value as T];
}

/// Convert any value to [Map<String, dynamic>]
/// 
/// Safely converts any value to Map or returns empty map
/// 
/// Handles:
/// - Map: returns as-is (casted)
/// - null: returns empty map
/// - other: returns empty map with error log
/// 
/// Example:
/// ```dart
/// toMap({"key": "value"})  // → {"key": "value"}
/// toMap(null)              // → {}
/// toMap("invalid")         // → {} (with error log)
/// ```
Map<String, dynamic> toMap(dynamic value, {String? fieldName}) {
  if (value == null) return {};

  if (value is Map) {
    try {
      return Map<String, dynamic>.from(value);
    } catch (e) {
      _logConversionError('Map<String, dynamic>', value, fieldName, e);
      return {};
    }
  }

  _logTypeError('Map', value.runtimeType, fieldName);
  return {};
}

/// Safe list access with default value
/// 
/// Returns element at index or defaultValue if index is out of bounds
/// 
/// Example:
/// ```dart
/// getListItem([1, 2, 3], 1)        // → 2
/// getListItem([1, 2, 3], 10)       // → null
/// getListItem([1, 2, 3], 10, -1)   // → -1
/// getListItem(null, 0)             // → null
/// ```
T? getListItem<T>(
  List<T>? list,
  int index, {
  T? defaultValue,
  String? fieldName,
}) {
  if (list == null || list.isEmpty) return defaultValue;
  if (index < 0 || index >= list.length) {
    if (fieldName != null) {
      print('[TYPE_CONVERSION] List index out of bounds: '
          'field=$fieldName, index=$index, length=${list.length}');
    }
    return defaultValue;
  }
  return list[index];
}

/// Safe map access with type conversion
/// 
/// Retrieves value from map and converts to specified type
/// 
/// Example:
/// ```dart
/// final map = {"age": "25", "name": "John"};
/// 
/// getMapValue<int>(map, "age")        // → 25
/// getMapValue<String>(map, "name")    // → "John"
/// getMapValue<int>(map, "missing")    // → null
/// getMapValue<int>(map, "missing", 0) // → 0
/// ```
T? getMapValue<T>(
  Map<String, dynamic>? map,
  String key, {
  T? defaultValue,
  bool convertType = true,
}) {
  if (map == null || !map.containsKey(key)) return defaultValue;

  final value = map[key];
  if (value == null) return defaultValue;

  if (!convertType) {
    try {
      return value as T;
    } catch (e) {
      return defaultValue;
    }
  }

  // Type conversion logic
  if (T == int) {
    return toInt(value) as T?;
  } else if (T == double) {
    return toDouble(value) as T?;
  } else if (T == bool) {
    return toBool(value) as T?;
  } else if (T == String) {
    return toString(value) as T?;
  } else if (T == List) {
    return toList(value) as T?;
  } else if (T == Map) {
    return toMap(value) as T?;
  }

  try {
    return value as T;
  } catch (e) {
    return defaultValue;
  }
}

/// Check if value is numeric (int or double)
bool isNumeric(dynamic value) {
  return value is int || value is double;
}

/// Check if value is numeric string
bool isNumericString(dynamic value) {
  if (value is! String) return false;
  if (value.isEmpty) return false;
  return double.tryParse(value) != null;
}

/// Check if value is empty (null, empty string, empty list, empty map)
bool isEmpty(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.isEmpty;
  if (value is List) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

/// Check if value is not empty
bool isNotEmpty(dynamic value) => !isEmpty(value);

// ============================================================================
// Private Logging Helpers
// ============================================================================

void _logConversionError(
  String targetType,
  dynamic value,
  String? fieldName,
  dynamic error,
) {
  print('[TYPE_CONVERSION_ERROR] Failed to convert to $targetType'
      '${fieldName != null ? ' (field: $fieldName)' : ''}: '
      'value=$value, error=$error');
}

void _logTypeError(
  String targetType,
  Type actualType,
  String? fieldName,
) {
  print('[TYPE_CONVERSION_ERROR] Unsupported type conversion'
      '${fieldName != null ? ' (field: $fieldName)' : ''}: '
      'target=$targetType, actual=$actualType');
}
