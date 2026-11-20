import 'dart:convert';

import 'package:dentify_flutter/iam/data/remote/dto/login_request.dart';
import 'package:dentify_flutter/iam/data/remote/dto/register_request.dart';
import 'package:dentify_flutter/iam/data/remote/services/auth_api_service.dart';
import 'package:dentify_flutter/iam/data/remote/services/session_validator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _base = 'https://example.com/api/';

RegisterRequest _registerRequest() => RegisterRequest(
      firstName: 'Valeria',
      lastName: 'Campos',
      email: 'demo@dentify.test',
      companyName: 'Consultorio',
      username: 'valeria',
      password: 'Clave-12345',
      trial: true,
    );

void main() {
  group('AuthApiService', () {
    test('register accepts the 201 Created that the service returns', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'accessToken': 'a', 'refreshToken': 'r', 'username': 'valeria'}),
            201,
          ));
      final response = await AuthApiService(_base, client: client).register(_registerRequest());
      expect(response.accessToken, 'a');
    });

    test('login shows the service message instead of a raw HTTP code', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'error': 'Password cannot be empty'}),
            400,
          ));
      expect(
        () => AuthApiService(_base, client: client).login(LoginRequest(username: 'demo', password: '')),
        throwsA(isA<AuthApiException>()
            .having((e) => e.toString(), 'mensaje', 'Password cannot be empty')
            .having((e) => e.statusCode, 'código', 400)),
      );
    });

    test('wrong credentials read as a clear message', () async {
      final client = MockClient((_) async => http.Response('', 401));
      expect(
        () => AuthApiService(_base, client: client).login(LoginRequest(username: 'demo', password: 'mala')),
        throwsA(isA<AuthApiException>()
            .having((e) => e.toString(), 'mensaje', 'Usuario o contraseña incorrectos.')),
      );
    });

    test('an unexpected error keeps a readable fallback with its code', () async {
      final client = MockClient((_) async => http.Response('<html>boom</html>', 500));
      expect(
        () => AuthApiService(_base, client: client).register(_registerRequest()),
        throwsA(isA<AuthApiException>()
            .having((e) => e.toString(), 'mensaje', 'No se pudo crear la cuenta (HTTP 500).')),
      );
    });
  });

  group('SessionValidator', () {
    test('a token the service accepts is valid and is sent as Bearer', () async {
      http.Request? captured;
      final client = MockClient((request) async {
        captured = request;
        return http.Response('{}', 200);
      });
      expect(await SessionValidator(_base, client: client).check('token-1'), SessionStatus.valid);
      expect(captured?.url, Uri.parse('https://example.com/api/v1/profile'));
      expect(captured?.headers['Authorization'], 'Bearer token-1');
    });

    test('401 and 403 mean the stored session is no longer valid', () async {
      for (final code in [401, 403]) {
        final client = MockClient((_) async => http.Response('', code));
        expect(await SessionValidator(_base, client: client).check('viejo'), SessionStatus.invalid);
      }
    });

    test('a network failure does not log the user out', () async {
      final client = MockClient((_) async => throw http.ClientException('sin red'));
      expect(await SessionValidator(_base, client: client).check('token'), SessionStatus.unknown);
    });
  });
}
