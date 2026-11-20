import 'dart:math';

import 'package:dentify_flutter/payment/domain/model/request_id.dart';
import 'package:flutter_test/flutter_test.dart';

import 'payment_test_support.dart';

/// Fuente "aleatoria" que siempre devuelve el mismo byte.
class _ConstantRandom implements Random {
  _ConstantRandom(this.value);

  final int value;

  @override
  int nextInt(int max) => value % max;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}

void main() {
  group('generateRequestId', () {
    test('produces lowercase UUID v4 strings', () {
      for (var i = 0; i < 1000; i++) {
        final id = generateRequestId();
        expect(id, matches(uuidV4Pattern), reason: id);
      }
    });

    test('does not repeat over 1000 generations', () {
      final ids = {for (var i = 0; i < 1000; i++) generateRequestId()};
      expect(ids, hasLength(1000));
    });

    test('forces the version and variant bits whatever the random bytes', () {
      expect(
        generateRequestId(_ConstantRandom(0xff)),
        'ffffffff-ffff-4fff-bfff-ffffffffffff',
      );
      expect(
        generateRequestId(_ConstantRandom(0x00)),
        '00000000-0000-4000-8000-000000000000',
      );
    });
  });
}
