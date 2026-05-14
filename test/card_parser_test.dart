import 'package:flutter_test/flutter_test.dart';
import 'package:ocrvault/services/card_parser.dart';

void main() {
  test('Card parser extracts valid data', () {
    final result = CardParser.parseCard(
      '''
      4111 1111 1111 1111
      12/28
      HIREN MAKWANA
      ''',
    );

    expect(result.cardNumber.contains('1111'), true);
    expect(result.expiryDate, '12/28');
    expect(result.cardHolder, 'HIREN MAKWANA');
  });
}