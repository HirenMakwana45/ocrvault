import 'package:flutter_test/flutter_test.dart';
import 'package:ocrvault/services/luhn_validator.dart';

void main() {
  test('Valid card passes Luhn', () {
    expect(
      LuhnValidator.isValidCard(
        '4111111111111111',
      ),
      true,
    );
  });
}