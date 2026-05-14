import '../model/card_details.dart';
import 'luhn_validator.dart';

class CardParser {
  static CardDetails parseCard(String rawText) {
    final text = _normalize(rawText);

    final lines = text
        .split('\n')
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();

    final mergedText = lines.join(' ');

    String cardNumber = '';
    String expiryDate = '';
    String cardHolder = '';

    /// =========================================
    /// CARD NUMBER
    /// =========================================

    List<String> chunks = [];

    for (String line in lines) {

      String cleaned = line
          .replaceAll('O', '0')
          .replaceAll('I', '1')
          .replaceAll('L', '1')
          .replaceAll('S', '5')
          .replaceAll('B', '8');

      /// extract numeric groups
      final matches =
      RegExp(r'[0-9]{4,}')
          .allMatches(cleaned);

      for (final match in matches) {

        final chunk =
        match.group(0)!;

        /// avoid expiry-like numbers
        if (chunk.length >= 4) {
          chunks.add(chunk);
        }
      }
    }

    /// rebuild sequences
    List<String> candidates = [];

    for (int i = 0;
    i < chunks.length;
    i++) {

      String current = '';

      for (int j = i;
      j < chunks.length;
      j++) {

        current += chunks[j];

        if (current.length >= 13 &&
            current.length <= 19) {

          if (LuhnValidator.isValidCard(current)) {
            candidates.add(current);
          }
        }

        if (current.length > 19) {
          break;
        }
      }
    }

    if (candidates.isNotEmpty) {

      candidates.sort(
            (a, b) =>
            b.length.compareTo(a.length),
      );

      cardNumber =
          _maskCard(candidates.first);
    }

    /// =========================================
    /// EXPIRY DATE
    /// =========================================

    final expiryRegex = RegExp(
      r'(0[1-9]|1[0-2])[\/\-](\d{2,4})',
    );

    for (String line in lines) {

      String cleaned = line
          .replaceAll('O', '0')
          .replaceAll('I', '1')
          .replaceAll('L', '1')
          .replaceAll('S', '5');

      final match =
      expiryRegex.firstMatch(cleaned);

      if (match != null) {

        String year =
        match.group(2)!;

        if (year.length == 4) {
          year = year.substring(2);
        }

        expiryDate =
        '${match.group(1)}/$year';

        break;
      }
    }
    /// =========================================
    /// CARD HOLDER NAME
    /// =========================================

    final blockedWords = [

      'VALID',
      'THRU',
      'BANK',
      'CARD',
      'VISA',
      'MASTERCARD',
      'RUPAY',
      'DEBIT',
      'CREDIT',
      'PLATINUM',
      'GOLD',
      'DATE',
      'SECURITY',
      'CODE',
      'REWARD',
      'INTEREST',
      'CUSTOMER',
      'CARE',
      'SUPER',
      'FLIPKART',
      'AMAZON',
      'PAYTM',
      'SHOPPING',
      'IDFC',
      'FIRST',
    ];

    for (String line in lines) {
      String cleaned = line
          .replaceAll(RegExp(r'[^A-Z ]'), '')
          .trim();

      cleaned = _fixOCRName(cleaned);

      bool blocked = false;

      for (String word in blockedWords) {
        if (cleaned.contains(word)) {
          blocked = true;
          break;
        }
      }

      final words = cleaned
          .split(' ')
          .where((e) => e.isNotEmpty)
          .toList();

      final isName =
      RegExp(r'^[A-Z ]+$')
          .hasMatch(cleaned);

      if (isName &&
          !blocked &&
          words.length >= 2 &&
          words.length <= 4 &&
          cleaned.length >= 5) {

        cardHolder = cleaned;
        break;
      }
    }

    return CardDetails(
      cardNumber: cardNumber,
      expiryDate: expiryDate,
      cardHolder: cardHolder,
    );
  }

  static String _normalize(String text) {
    return text
        .toUpperCase()
        .replaceAll('|', ' ')
        .replaceAll('_', ' ')
        .replaceAll(',', ' ')
        .replaceAll(RegExp(r'[ ]+'), ' ')
        .trim();
  }

  static String _fixOCRName(String text) {
    return text
        .replaceAll('0', 'O')
        .replaceAll('1', 'I')
        .replaceAll('5', 'S')
        .replaceAll('8', 'B');
  }

  static String _maskCard(String number) {
    final last4 =
    number.substring(number.length - 4);

    return 'XXXX XXXX XXXX $last4';
  }
}