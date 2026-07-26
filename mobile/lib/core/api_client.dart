/// Minimal API client wrapper for the InariSense backend.
///
/// IMPORTANT — baseUrl differs by where you're running the app during
/// local development, and getting this wrong is the most common cause of
/// "connection refused" errors:
///
/// - Android emulator: http://10.0.2.2:8000
///   (10.0.2.2 is a special alias the Android emulator maps to your
///   host machine's localhost — 127.0.0.1 from INSIDE the emulator
///   means the emulator itself, not your dev machine.)
/// - iOS simulator: http://127.0.0.1:8000
///   (the iOS simulator shares your Mac's network stack directly, so
///   localhost/127.0.0.1 works as expected.)
/// - Physical device (either platform): your dev machine's LAN IP,
///   e.g. http://192.168.1.50:8000 — the device is on the same Wi-Fi
///   network as your machine, not literally the same host.
///
/// This is hard-coded to the Android emulator default for now since
/// that's what's been used for backend testing so far. Swap the
/// baseUrl below (or wire it to an environment-based config) once
/// you're testing on iOS or a physical device.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiResponse {
  final int statusCode;
  final dynamic data;

  ApiResponse({required this.statusCode, required this.data});
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

    dynamic decoded;
    try {
      decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decoded = null;
    }

    return ApiResponse(statusCode: response.statusCode, data: decoded);
  }
}
