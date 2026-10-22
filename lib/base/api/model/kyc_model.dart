enum KycFieldType {
  text('text'),
  textarea('textarea'),
  number('number'),
  date('date'),
  select('select'),
  file('file');

  final String value;
  const KycFieldType(this.value);

  static KycFieldType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'text':
        return KycFieldType.text;
      case 'textarea':
        return KycFieldType.textarea;
      case 'number':
        return KycFieldType.number;
      case 'date':
        return KycFieldType.date;
      case 'select':
        return KycFieldType.select;
      case 'file':
        return KycFieldType.file;
      default:
        return KycFieldType.text;
    }
  }
}

class KycFieldsResponseModel {
  final bool success;
  final String message;
  final List<KycField>? fields;

  KycFieldsResponseModel({
    required this.success,
    required this.message,
    this.fields,
  });

  factory KycFieldsResponseModel.fromJson(Map<String, dynamic> json) {
    // Extract message properly - handle nested success message
    String messageText = '';
    if (json['message'] is Map) {
      final msgMap = json['message'] as Map<String, dynamic>;
      if (msgMap['success'] is List && (msgMap['success'] as List).isNotEmpty) {
        messageText = (msgMap['success'] as List).first.toString();
      } else if (msgMap['error'] is List && (msgMap['error'] as List).isNotEmpty) {
        messageText = (msgMap['error'] as List).first.toString();
      }
    } else if (json['message'] is List) {
      messageText = (json['message'] as List).join(', ');
    } else {
      messageText = json['message']?.toString() ?? '';
    }

    // Extract kyc_fields from nested data object
    List<KycField> fieldsList = [];
    if (json['data'] != null && json['data'] is Map) {
      final dataMap = json['data'] as Map<String, dynamic>;
      if (dataMap['kyc_fields'] != null && dataMap['kyc_fields'] is List) {
        fieldsList = (dataMap['kyc_fields'] as List)
            .map((e) => KycField.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return KycFieldsResponseModel(
      success: (json['type'] == 'success') || (json['success'] ?? false),
      message: messageText,
      fields: fieldsList,
    );
  }
}

class KycField {
  final String name;
  final String label;
  final KycFieldType type;
  final bool required;
  final List<String>? options;
  final String? placeholder;
  final int? maxLength;
  final String? validationRegex;

  KycField({
    required this.name,
    required this.label,
    required this.type,
    required this.required,
    this.options,
    this.placeholder,
    this.maxLength,
    this.validationRegex,
  });

  factory KycField.fromJson(Map<String, dynamic> json) {
    // Extract maxLength from validation.max if available
    int? maxLength;
    if (json['validation'] is Map) {
      final validation = json['validation'] as Map<String, dynamic>;
      if (validation['max'] != null) {
        maxLength = int.tryParse(validation['max'].toString());
      }
    } else if (json['max_length'] != null) {
      maxLength = int.tryParse(json['max_length'].toString());
    }

    return KycField(
      name: json['name']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      type: KycFieldType.fromString(json['type']?.toString() ?? 'text'),
      required: json['required'] == true || json['required'] == 1,
      options: json['options'] != null && json['options'] is List
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : null,
      placeholder: json['placeholder']?.toString(),
      maxLength: maxLength,
      validationRegex: json['validation_regex']?.toString(),
    );
  }
}

class KycSubmitResponseModel {
  final bool success;
  final String message;
  final KycSubmitData? data;

  KycSubmitResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory KycSubmitResponseModel.fromJson(Map<String, dynamic> json) {
    return KycSubmitResponseModel(
      success: json['success'] ?? true,
      message: (json['message'] is List)
          ? (json['message'] as List).join(', ')
          : json['message']?.toString() ?? '',
      data: json['data'] != null ? KycSubmitData.fromJson(json['data']) : null,
    );
  }
}

class KycSubmitData {
  final int kycStatus;
  final String nextAction;

  KycSubmitData({
    required this.kycStatus,
    required this.nextAction,
  });

  factory KycSubmitData.fromJson(Map<String, dynamic> json) {
    return KycSubmitData(
      kycStatus: int.tryParse(json['kyc_status']?.toString() ?? '2') ?? 2,
      nextAction: json['next_action']?.toString() ?? 'none',
    );
  }
}
