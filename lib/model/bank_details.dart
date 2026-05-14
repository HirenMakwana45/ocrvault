class BankDetails {
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;

  BankDetails({
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
  });

  bool get isEmpty =>
      accountHolder.isEmpty &&
          accountNumber.isEmpty &&
          ifscCode.isEmpty;
}