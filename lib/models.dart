class CreditCard {
  final String number;
  final String type;
  final String cvv;
  final String issuingCountry;
  final String expiryDate;
  final String cardHolderName;

  CreditCard({
    required this.number,
    required this.type,
    required this.cvv,
    required this.issuingCountry,
    required this.expiryDate,
    required this.cardHolderName, required String country,
  });

  // Backwards-compatible alias for UI code that expects 'country'
  String get country => issuingCountry;

  CreditCard copyWith({
    String? number,
    String? type,
    String? cvv,
    String? issuingCountry,
    String? expiryDate,
    String? cardHolderName,
  }) {
    return CreditCard(
      number: number ?? this.number,
      type: type ?? this.type,
      cvv: cvv ?? this.cvv,
      issuingCountry: issuingCountry ?? this.issuingCountry,
      expiryDate: expiryDate ?? this.expiryDate,
      cardHolderName: cardHolderName ?? this.cardHolderName, country: '',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'type': type,
        'cvv': cvv,
        'issuingCountry': issuingCountry,
        'expiryDate': expiryDate,
        'cardHolderName': cardHolderName,
      };

  factory CreditCard.fromJson(Map<String, dynamic> json) => CreditCard(
        number: json['number'],
        type: json['type'],
        cvv: json['cvv'],
        issuingCountry: json['issuingCountry'],
        expiryDate: json['expiryDate'],
        cardHolderName: json['cardHolderName'], 
        country: '',
      );
}

class BannedCountry {
  final String name;

  BannedCountry({required this.name});

  Map<String, dynamic> toJson() => {
        'name': name,
      };

  factory BannedCountry.fromJson(Map<String, dynamic> json) => BannedCountry(
        name: json['name'],
      );
}