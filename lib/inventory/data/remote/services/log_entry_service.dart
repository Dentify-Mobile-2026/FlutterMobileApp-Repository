import 'dart:convert';
import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:dentify_flutter/iam/data/storage/token_storage.dart';
import 'package:dentify_flutter/inventory/data/model/log_entry_response.dart';
import 'package:http/http.dart' as http;

class LogEntryService {
  final String baseUrl;

  LogEntryService(this.baseUrl);

  Future<List<LogEntryResponse>> getAllLogEntries() async {
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      ApiConstants.endpoint(baseUrl, 'v1/log-entries'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((item) => LogEntryResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Failed to load log entries (${response.statusCode})');
    }
  }
}
