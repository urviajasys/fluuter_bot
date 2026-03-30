import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

class ApiClient {
  const ApiClient();

  Future<Map<String, dynamic>> getJson(String path) async {
    final response = await http.get(Uri.parse('${AppConfig.backendBaseUrl}$path'));
    log("GET URL ${AppConfig.backendBaseUrl}$path   RES CODE  ${response.statusCode}    ${response.body}");
    return _decode(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConfig.backendBaseUrl}$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    log("POST URL ${AppConfig.backendBaseUrl}$path   RES CODE  ${response.statusCode}    ${response.body}");
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final payload = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(payload['message'] ?? payload['error'] ?? response.body);
    }

    return payload;
  }
}

