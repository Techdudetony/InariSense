/// Minimal API client wrapper for the InariSense backend.
///
/// IMPORTANT — baseUrl differs by where you're running the app during
/// local development:
/// - Android emulator: http://10.0.2.2:8000
/// - iOS simulator: http://127.0.0.1:8000
/// - Physical device: your dev machine's LAN IP.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  final int statusCode;
  final dynamic data;

  ApiResponse({required this.statusCode, required this.data});
}

/// One image part for a multipart upload — fieldName is the form field
/// name the backend expects (e.g. "images"), matching FastAPI's
/// `images: list[UploadFile] = File(...)`.
class MultipartImagePart {
  final String fieldName;
  final List<int> bytes;
  final String filename;

  MultipartImagePart(
      {required this.fieldName, required this.bytes, required this.filename});
}

class ApiClient {
  ApiClient._(this.baseUrl);

  static final ApiClient instance = ApiClient._('http://10.0.2.2:8000');

  final String baseUrl;

  Future<ApiResponse> post(String path,
      {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<ApiResponse> patch(String path,
      {required Map<String, dynamic> body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<ApiResponse> get(String path,
      {Map<String, dynamic>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters:
          queryParams?.map((key, value) => MapEntry(key, value.toString())),
    );
    final response = await http.get(uri);
    return _decode(response);
  }

  /// Multipart POST — used for the identification upload, which needs
  /// both files (images) and repeated non-file fields (organs, one per
  /// image). http.MultipartRequest.fields is a plain `Map<String,String>`
  /// and can't represent repeated keys, so every field here (including
  /// plain text ones like user_id and organs) is added via
  /// request.files using MultipartFile.fromString with no filename —
  /// that's what makes a part behave as a plain form field rather than
  /// an uploaded file on the wire, and it's the only way this http
  /// package version supports sending the same field name more than
  /// once in one request.
  Future<ApiResponse> postMultipart(
    String path, {
    required List<MapEntry<String, String>> fields,
    required List<MultipartImagePart> imageParts,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    for (final entry in fields) {
      request.files.add(http.MultipartFile.fromString(entry.key, entry.value));
    }
    for (final part in imageParts) {
      request.files.add(
        http.MultipartFile.fromBytes(part.fieldName, part.bytes,
            filename: part.filename),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _decode(response);
  }

  ApiResponse _decode(http.Response response) {
    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decoded = null;
    }
    return ApiResponse(statusCode: response.statusCode, data: decoded);
  }
}
