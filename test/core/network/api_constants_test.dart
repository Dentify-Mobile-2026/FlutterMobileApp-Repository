import 'package:dentify_flutter/core/network/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('endpoint appends paths without duplicating or dropping base path', () {
    expect(
      ApiConstants.endpoint('https://example.com/api/', 'v1/patients'),
      Uri.parse('https://example.com/api/v1/patients'),
    );
    expect(
      ApiConstants.endpoint('https://example.com/api', 'v1/items/42'),
      Uri.parse('https://example.com/api/v1/items/42'),
    );
  });
}
