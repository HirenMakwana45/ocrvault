import 'package:flutter_test/flutter_test.dart';

import '../services/passbook_parser.dart';

void main() {

  test('Passbook parser test', () {

    const raw = '''
    Customer Name: HIREN MAKWANA
    Account No: 12345678901
    IFSC: SBIN0001234
    ''';

    final result =
    PassbookParser.parsePassbook(raw);

    expect(
      result.ifscCode,
      'SBIN0001234',
    );
  });
}