import 'package:dentify_flutter/payment/domain/model/money.dart';
import 'package:dentify_flutter/payment/presentation/widgets/invoice_form_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money.parse', () {
    test('accepts comma or dot as decimal separator', () {
      expect(Money.parse('120,50').cents, 12050);
      expect(Money.parse('120.5').cents, 12050);
      expect(Money.parse('120,5').cents, 12050);
      expect(Money.parse('350').cents, 35000);
      expect(Money.parse('0.07').cents, 7);
      expect(Money.parse(' 99.9 ').cents, 9990);
    });

    test('rejects more than 2 decimals, letters and malformed input', () {
      for (final input in [
        '120.555',
        'abc',
        '',
        '12a',
        '-5',
        '1.2.3',
        '.50',
        '50.',
        '123456789',
      ]) {
        expect(Money.tryParse(input), isNull, reason: 'input "$input"');
        expect(() => Money.parse(input), throwsFormatException,
            reason: 'input "$input"');
      }
    });

    test('accepts up to 8 integer digits', () {
      expect(Money.parse('99999999.99').cents, 9999999999);
    });

    test('"0" is a valid amount but the invoice form rejects it', () {
      final zero = Money.parse('0');
      expect(zero.isZero, isTrue);
      expect(zero, Money.zero);

      expect(InvoiceFormDialog.validateAmount('0'), 'El monto debe ser mayor a 0');
      expect(InvoiceFormDialog.validateAmount('0,00'), 'El monto debe ser mayor a 0');
      expect(InvoiceFormDialog.validateAmount('120.555'),
          'Ingrese un monto válido (máx. 2 decimales)');
      expect(InvoiceFormDialog.validateAmount('abc'),
          'Ingrese un monto válido (máx. 2 decimales)');
      expect(InvoiceFormDialog.validateAmount(''), 'Ingrese el monto a cobrar');
      expect(InvoiceFormDialog.validateAmount('120,5'), isNull);
    });
  });

  group('Money.fromJson', () {
    test('rounds server values to the nearest cent', () {
      expect(Money.fromJson(120.5).cents, 12050);
      expect(Money.fromJson(0.29).cents, 29);
      expect(Money.fromJson(350).cents, 35000);
    });
  });

  group('Money formatting', () {
    test('toApiString always uses a dot and 2 decimals', () {
      expect(Money.parse('120,5').toApiString(), '120.50');
      expect(Money.parse('7').toApiString(), '7.00');
      expect(const Money.fromCents(5).toApiString(), '0.05');
      expect(const Money.fromCents(-1250).toApiString(), '-12.50');
    });

    test('format adds the soles prefix', () {
      expect(Money.parse('120.5').format(), 'S/. 120.50');
      expect(Money.zero.format(), 'S/. 0.00');
    });
  });

  group('Money comparison and arithmetic', () {
    test('compares by cents', () {
      final small = Money.parse('10.00');
      final big = Money.parse('10.01');
      expect(small < big, isTrue);
      expect(big > small, isTrue);
      expect(small <= Money.parse('10'), isTrue);
      expect(big >= small, isTrue);
      expect(small.compareTo(big), lessThan(0));
      expect(Money.parse('10,0'), Money.parse('10.00'));
      expect(Money.parse('10,0').hashCode, Money.parse('10.00').hashCode);
    });

    test('adds and subtracts without floating point drift', () {
      final total = Money.parse('0.10') + Money.parse('0.20');
      expect(total, Money.parse('0.30'));
      expect((Money.parse('100') - Money.parse('0.01')).toApiString(), '99.99');
    });
  });
}
