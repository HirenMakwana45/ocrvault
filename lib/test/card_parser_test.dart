import 'package:flutter_test/flutter_test.dart';

import '../services/card_parser.dart';

void main() {

  test('Card parser test', () {

    const raw = '''
    4532 0151 1283 0366
    VALID 04/28
    HIREN MAKWANA
    ''';

    final result =
    CardParser.parseCard(raw);

    expect(
      result.expiryDate,
      '04/28',
    );
  });
}