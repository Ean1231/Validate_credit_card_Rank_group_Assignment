import 'package:flutter/material.dart';
import '../models.dart';
import '../widgets/card_display/styled_card_display.dart';

class SavedCardsScreen extends StatelessWidget {
  final List<CreditCard> cards;
  const SavedCardsScreen({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Cards'),
        centerTitle: true,
      ),
      body: cards.isEmpty
          ? const Center(child: Text('No saved cards'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final card = cards[index];
                return StyledCardDisplay(
                  number: card.number,
                  type: card.type,
                  country: card.country,
                  expiryDate: card.expiryDate,
                  cardHolderName: card.cardHolderName,
                );
              },
            ),
    );
  }
}
