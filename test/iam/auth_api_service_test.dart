import 'dart:convert';

import 'package:dentify_flutter/iam/data/remote/dto/login_request.dart';
import 'package:dentify_flutter/iam/data/remote/services/auth_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('login sends credentials to the auth login endpoint', () async {
    http.Request? capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode({'accessToken': 'access', 'refreshToken': 'refresh'}),
        200,
      );
    });
    final service = AuthApiService('https://example.com/api/', client: client);

    await service.login(LoginRequest(username: 'dentist', password: 'secret'));

    expect(capturedRequest?.method, 'POST');
    expect(
      capturedRequest?.url,
      Uri.parse('https://example.com/api/auth/login'),
    );
    expect(jsonDecode(capturedRequest!.body), {
      'username': 'dentist',
      'password': 'secret',
    });
    expect(
      capturedRequest?.headers['content-type'],
      startsWith('application/json'),
    );
  });
}
