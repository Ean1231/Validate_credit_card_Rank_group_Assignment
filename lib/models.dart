class CreditCard {
  final String number;
  final String type;
  final String cvv;
  final String issuingCountry;
    final String expiryDate;
    final String cardHolderName;

  CreditCard( {
    required this.number,
    required this.type,
    required this.cvv,
    required this.issuingCountry, 
    required this.expiryDate, 
    required String country, 
    required this.cardHolderName,
  });

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
        country: '',
        cardHolderName: json['cardHolderName'],  // default empty, can be set later
      );

  get country => null;
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