
import '../model/bank_details.dart';

class PassbookParser {
  static BankDetails parsePassbook(String rawText) {

    /// =========================================
    /// RAW LINES
    /// =========================================

    final lines = rawText
        .split('\n')
        .map((e) => e.trim().toUpperCase())
        .where((e) => e.isNotEmpty)
        .toList();

    /// =========================================
    /// OCR NORMALIZATION
    /// =========================================

    List<String> normalizedLines =
    lines.map((line) {
      return line
          .replaceAll('1FSC', 'IFSC')
          .replaceAll('IFSCC', 'IFSC')
          .replaceAll('NANE', 'NAME')
          .replaceAll('CUSTONER', 'CUSTOMER')
          .replaceAll('S81', 'SBI')
          .replaceAll('SB1', 'SBI')
          .replaceAll('INO', 'IN0')
          .replaceAll('|', ' ')
          .replaceAll('_', ' ')
          .replaceAll(',', ' ')
          .trim();
    }).toList();

    String accountNumber = '';
    String ifscCode = '';
    String accountHolder = '';

    /// =========================================
    /// ACCOUNT HOLDER NAME
    /// =========================================

    for (String line in normalizedLines) {

      if (line.contains('CUSTOMER NAME') ||
          line.contains('ACCOUNT NAME') ||
          line.contains('ACCOUNT HOLDER') ||
          line.contains('NAME')) {

        String cleaned = line;

        cleaned = cleaned
            .replaceAll('CUSTOMER NAME', '')
            .replaceAll('ACCOUNT HOLDER NAME', '')
            .replaceAll('ACCOUNT HOLDER', '')
            .replaceAll('ACCOUNT NAME', '')
            .replaceAll('NAME', '')
            .replaceAll(':', '')
            .replaceAll('MR.', '')
            .replaceAll('MR', '')
            .replaceAll(RegExp(r'[^A-Z ]'), '')
            .trim();

        cleaned = _fixOCRName(cleaned);

        final blocked =
            cleaned.contains('BANK') ||
                cleaned.contains('BRANCH') ||
                cleaned.contains('ADDRESS');

        if (cleaned.length > 2 &&
            !blocked) {
          accountHolder = cleaned;
          break;
        }
      }
    }

    /// =========================================
    /// ACCOUNT NUMBER
    /// =========================================

    for (int i = 0;
    i < normalizedLines.length;
    i++) {

      final line = normalizedLines[i];

      if (line.contains('ACCOUNT NO') ||
          line.contains('ACCOUNT NUMBER') ||
          line.contains('A/C')) {

        List<String> possibleNumbers = [];

        /// scan nearby lines
        for (int j = i + 1;
        j <= i + 12 &&
            j < normalizedLines.length;
        j++) {

          final nextLine =
          normalizedLines[j];

          /// stop only at metadata sections
          if (nextLine.contains('IFSC') ||
              nextLine.contains('MICR') ||
              nextLine.contains('BRANCH CODE') ||
              nextLine.contains('DATE OF ISSUE')) {
            break;
          }

          final matches =
          RegExp(r'\d{9,18}')
              .allMatches(nextLine);

          for (final match in matches) {
            final value =
            match.group(0)!;

            /// ignore obvious non-account numbers
            if (value.length >= 10) {
              possibleNumbers.add(value);
            }
          }
        }

        /// choose LAST number
        /// usually account number after CIF
        if (possibleNumbers.isNotEmpty) {
          accountNumber =
              possibleNumbers.last;
        }

        break;
      }
    }

    /// =========================================
    /// FALLBACK ACCOUNT NUMBER
    /// =========================================

    if (accountNumber.isEmpty) {

      List<String> allNumbers = [];

      for (String line in normalizedLines) {

        final matches =
        RegExp(r'\d{9,18}')
            .allMatches(line);

        for (final match in matches) {

          final value =
          match.group(0)!;

          /// ignore MICR lines
          if (line.contains('MICR')) {
            continue;
          }

          /// ignore date/year numbers
          if (value.contains('2017') ||
              value.contains('2018') ||
              value.contains('2019') ||
              value.contains('2020') ||
              value.contains('2021') ||
              value.contains('2022') ||
              value.contains('2023') ||
              value.contains('2024')) {
            continue;
          }

          allNumbers.add(value);
        }
      }

      if (allNumbers.isNotEmpty) {

        /// choose longest
        allNumbers.sort(
              (a, b) =>
              b.length.compareTo(a.length),
        );

        accountNumber =
            allNumbers.first;
      }
    }
    /// =========================================
    /// IFSC CODE
    /// =========================================

    for (String line in normalizedLines) {

      if (line.contains('IFSC') ||
          line.contains('1FSC')) {

        String candidate = line;

        candidate = candidate
            .replaceAll('IFSC', '')
            .replaceAll('1FSC', '')
            .replaceAll(':', '')
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .trim();

        /// OCR FIXES
        candidate = candidate
            .replaceAll('O', '0')
            .replaceAll('I', '1')
            .replaceAll('L', '1');

        /// SBI OCR fixes
        candidate = candidate
            .replaceAll('58I', 'SBI')
            .replaceAll('S8I', 'SBI')
            .replaceAll('5BI', 'SBI')
            .replaceAll('SB1', 'SBI');

        /// keep only alphanumeric
        candidate = candidate.replaceAll(
          RegExp(r'[^A-Z0-9]'),
          '',
        );
        /// first 4 chars should be letters
        if (candidate.length >= 4) {

          String prefix =
          candidate.substring(0, 4);

          prefix = prefix
              .replaceAll('5', 'S')
              .replaceAll('8', 'B')
              .replaceAll('1', 'I')
              .replaceAll('0', 'O');

          candidate =
              prefix + candidate.substring(4);
        }

        final regex =
        RegExp(r'[A-Z]{4}0\d{6}');

        final match =
        regex.firstMatch(candidate);

        if (match != null) {

          ifscCode = match.group(0)!;

          break;
        }

        /// fallback
        if (candidate.length >= 11) {

          ifscCode =
              candidate.substring(0, 11);
        }
      }
    }

    return BankDetails(
      accountHolder: accountHolder,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
    );
  }

  /// =========================================
  /// NAME OCR FIX
  /// =========================================

  static String _fixOCRName(String text) {
    return text
        .replaceAll('0', 'O')
        .replaceAll('5', 'S')
        .replaceAll('1', 'I')
        .replaceAll('8', 'B');
  }
}