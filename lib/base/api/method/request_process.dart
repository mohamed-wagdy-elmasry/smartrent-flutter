import 'package:get/get.dart';
import '../../utils/basic_import.dart';
import '../../widgets/logger.dart';
import '../endpoint/api_endpoint.dart';
import '../services/api_services.dart';

final log = logger(RequestProcess);

class RequestProcess extends GetxController {
  Future<T?> request<T>({
    required T Function(Map<String, dynamic>) fromJson,
    required ApiEndpoint apiEndpoint,
    required RxBool isLoading,
    bool showResult = false,
    bool showSuccessMessage = false,
    bool isBasic = false,
    required Function(T?) onSuccess,
    HttpMethod method = HttpMethod.GET,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Function(Object)? onError,
    List<String>? fieldList,
    List<String>? pathList,
    bool showErrorMessage = true,
  }) async {
    // Safely convert body to Map<String, String> if provided
    Map<String, String>? stringBody;
    if (body != null) {
      stringBody = body.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      );
    }
    try {
      isLoading.value = true;
      update();
      final String endpointUrl = apiEndpoint.url(params: queryParams);
      log.i(
        '📤 Request Starting\n'
        'Endpoint: $endpointUrl\n'
        'Method: $method\n'
        'Has Body: ${body != null}',
      );
      T? value;
      if (method == HttpMethod.POST && fieldList != null && pathList != null) {
        if (stringBody == null) {
          throw ArgumentError(
            'Body is required for multipart requests but was null',
          );
        }
        log.i(
          '📤 Multipart Upload Starting\n'
          'Fields: $fieldList\n'
          'Files: $pathList',
        );
        value = await ApiServices.multipartApiService<T>(
          fromJson,
          endpointUrl,
          stringBody,
          fieldList,
          pathList,
          showSuccessMessage: showSuccessMessage,
          isBasic: isBasic,
        );
      } else {
        log.i('📤 API Service Call Starting');
        value = await ApiServices.apiService<T>(
          fromJson,
          endpointUrl,
          method: method == HttpMethod.POST ? 'POST' : 'GET',
          body: body,
          showResult: showResult,
          isBasic: isBasic,
          showSuccessMessage: showSuccessMessage,
          showErrorMessage: showErrorMessage,
        );
      }

      if (value != null) {
        log.i(
          '✅ Request Completed Successfully\n'
          'Endpoint: $endpointUrl\n'
          'Result Type: ${value.runtimeType}',
        );
      }
      onSuccess(value);
      return value;
    } catch (e, stackTrace) {
      log.e(
        '❌ RequestProcess Exception\n'
        'Endpoint: ${apiEndpoint.url(params: queryParams)}\n'
        'Method: $method\n'
        'Error: $e\n'
        'Type: ${e.runtimeType}\n'
        'Stack Trace: $stackTrace',
      );
      if (onError != null) onError(e);
    } finally {
      isLoading.value = false;
      update();
    }
    return null;
  }
}

enum HttpMethod { GET, POST }
