import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'card_form.dart';
import 'card_display.dart';

void main() {
  runApp(const CreditCardApp());
}

class CreditCardApp extends StatelessWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Card Validation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CreditCard> _cards = [];
  List<String> _bannedCountries = [];
  bool _loading = true;

  CreditCard? _liveCard; // <-- live preview card

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList('cards') ?? [];
    final banned = prefs.getStringList('bannedCountries') ?? ['North Korea', 'Iran'];
    setState(() {
      _cards = cardsJson.map((e) => CreditCard.fromJson(jsonDecode(e))).toList();
      _bannedCountries = banned;
      _loading = false;
    });
  }

  Future<void> _saveCards(List<CreditCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'cards',
      cards.map((c) => jsonEncode(c.toJson())).toList(),
    );
  }

  void _addCard(CreditCard card) {
    setState(() {
      _cards.add(card);
      _liveCard = null; // clear live preview after adding
    });
    _saveCards(_cards);
  }

  void _updateBannedCountries(List<String> countries) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bannedCountries = countries;
    });
    await prefs.setStringList('bannedCountries', countries);
  }

  void _onCardChanged(CreditCard card) {
    setState(() {
      _liveCard = card;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Validation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
         if (_liveCard != null)
          CardDisplay(
            number: _liveCard!.number ?? '',
            type: _liveCard!.type ?? 'Unknown',
            country: _liveCard!.country ?? 'N/A',
            expiryDate: _liveCard!.expiryDate ?? 'N/A',
            cardHolderName: _liveCard!.cardHolderName ?? 'N/A',  // pass name here
          ),

            if (_liveCard != null) const SizedBox(height: 24),

            CardForm(
              bannedCountries: _bannedCountries,
              existingCards: _cards,
              onCardAdded: _addCard,
              onCardChanged: _onCardChanged, // pass live update callback
            ),

            const SizedBox(height: 24),

            const Text('Captured Cards:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            ..._cards.map((card) => CardDisplay(
              number: card.number ?? '',
              type: card.type ?? 'Unknown',
              country: card.country ?? 'N/A',
              expiryDate: card.expiryDate ?? 'N/A',
              cardHolderName: card.cardHolderName ?? '',  // pass name here
            )),
          ],
        ),
      ),
    );
  }
}
