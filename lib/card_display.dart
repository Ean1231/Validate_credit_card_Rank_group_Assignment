import 'package:flutter/material.dart';
import 'dart:ui';

class CardDisplay extends StatelessWidget {
  final String number;
  final String type;
  final String country;
  final String expiryDate;
  final String cardHolderName;


  const CardDisplay({
    super.key,
    required this.number,
    required this.type,
    required this.country,
    required this.expiryDate, 
    required this.cardHolderName,
  });

  static const Map<String, LinearGradient> cardTypeGradients = {
    'mastercard': LinearGradient(colors: [Color(0xFFEB001B), Color(0xFFF79E1B)]),
    'visa': LinearGradient(colors: [Color(0xFF1A1F71), Color(0xFF00A1E0)]),
    'american express': LinearGradient(colors: [Color(0xFF2E77BC), Color(0xFF6FB8E6)]),
  };

  static Widget _getCardLogo(String type) {
    final lowerType = type.toLowerCase();
    switch (lowerType) {
      case 'mastercard':
        return Image.network('https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png', height: 30);
     case 'visa':
     return Image.asset('assets/images/visa.png', height: 30);
      case 'american express':
        return Image.network('https://upload.wikimedia.org/wikipedia/commons/3/30/American_Express_logo_%282018%29.svg', height: 30);
      default:
        return const Icon(Icons.credit_card, size: 30, color: Colors.white70);
    }
  }

  String get formattedNumber {
    final clean = number.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);
      if ((i + 1) % 4 == 0 && i != clean.length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = cardTypeGradients[type.toLowerCase()] ??
        LinearGradient(colors: [Colors.grey.shade800, Colors.grey.shade600]);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: gradient.colors.last.withOpacity(0.5), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(alignment: Alignment.topRight, child: _getCardLogo(type)),
          const SizedBox(height: 16),
          Text(formattedNumber, style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2)),
          const SizedBox(height: 12),
          Text('Type: $type', style: const TextStyle(color: Colors.white70)),
          Text('Country: $country', style: const TextStyle(color: Colors.white70)),
          Text('Expiry Date: $expiryDate', style: const TextStyle(color: Colors.white70)),
          Text('Card holder: $cardHolderName', style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}