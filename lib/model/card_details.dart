class CardDetails {
  final String cardNumber;
  final String expiryDate;
  final String cardHolder;

  CardDetails({
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolder,
  });

  bool get isEmpty =>
      cardNumber.isEmpty &&
          expiryDate.isEmpty &&
          cardHolder.isEmpty;
}