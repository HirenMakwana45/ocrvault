import 'package:flutter_test/flutter_test.dart';
import 'package:ocrvault/services/passbook_parser.dart';

void main() {
  test('Passbook parser extracts bank details', () {
    final result = PassbookParser.parsePassbook(
      '''
      NAME : HIREN MAKWANA
      A/C NO : 458965214785
      IFSC : SBIN0004589
      ''',
    );

    expect(result.accountHolder, 'HIREN MAKWANA');
    expect(result.accountNumber, '458965214785');
    expect(result.ifscCode, 'SBIN0004589');
  });
}