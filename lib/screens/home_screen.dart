import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';
import '../features/card_form/card_form.dart';
import '../widgets/card_display/styled_card_display.dart';
import 'saved_cards_screen.dart';
import 'banned_countries_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CreditCard> _cards = [];
  List<String> _bannedCountries = [];
  bool _loading = true;
  CreditCard? _liveCard;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList('cards') ?? [];
    final banned = prefs.getStringList('bannedCountries') ?? [];
    final loadedCards = cardsJson.map((e) => CreditCard.fromJson(jsonDecode(e))).toList();
    final normalized = loadedCards.map((c) => c.copyWith(type: c.type.trim().toLowerCase())).toList();

    final placeholder = CreditCard(
      number: '**** **** **** 1234',
      type: 'unknown',
      cvv: '',
      issuingCountry: 'N/A',
      expiryDate: 'MM/YY',
      cardHolderName: 'CARD HOLDER',
      country: '',
    );

    setState(() {
      _cards = normalized;
      _bannedCountries = banned;
      _liveCard = placeholder;
      _loading = false;
    });
  }

  Future<void> _saveCards(List<CreditCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cards', cards.map((c) => jsonEncode(c.toJson())).toList());
  }

  void _addCard(CreditCard card) {
    final normalized = card.copyWith(type: card.type.trim().toLowerCase());
    setState(() {
      _cards.add(normalized);
    });
    _saveCards(_cards);
  }

  void _applyBannedCountries(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _bannedCountries = list);
    await prefs.setStringList('bannedCountries', list);
  }

  void _onCardChanged(CreditCard card) => setState(() => _liveCard = card.copyWith(type: card.type.trim().toLowerCase()));

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Validation'),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Align(alignment: Alignment.bottomLeft, child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24))),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('View Cards'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (_) => SavedCardsScreen(cards: _cards)));
              },
            ),
            ListTile(
              leading: const Icon(Icons.public_off),
              title: const Text('Banned Countries'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push<List<String>>(
                  context,
                  MaterialPageRoute(builder: (_) => BannedCountriesScreen(initial: _bannedCountries)),
                );
                if (result != null) _applyBannedCountries(result);
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledCardDisplay(
              number: _liveCard!.number,
              type: _liveCard!.type,
              country: _liveCard!.country,
              expiryDate: _liveCard!.expiryDate,
              cardHolderName: _liveCard!.cardHolderName,
            ),
            const SizedBox(height: 24),
            CardForm(
              bannedCountries: _bannedCountries,
              existingCards: _cards,
              onCardAdded: _addCard,
              onCardChanged: _onCardChanged,
            ),
          ],
        ),
      ),
    );
  }
}
