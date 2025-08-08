class CreditCard {
  final String number;
  final String type;
  final String cvv;
  final String issuingCountry;

  CreditCard({
    required this.number,
    required this.type,
    required this.cvv,
    required this.issuingCountry,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'type': type,
        'cvv': cvv,
        'issuingCountry': issuingCountry,
      };

  factory CreditCard.fromJson(Map<String, dynamic> json) => CreditCard(
        number: json['number'],
        type: json['type'],
        cvv: json['cvv'],
        issuingCountry: json['issuingCountry'],
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