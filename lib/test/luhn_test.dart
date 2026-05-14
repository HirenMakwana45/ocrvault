import 'package:flutter_test/flutter_test.dart';

import '../services/luhn_validator.dart';

void main() {

  test('Valid card test', () {

    bool result =
    LuhnValidator.isValidCard(
        '4532015112830366');

    expect(result, true);
  });
}