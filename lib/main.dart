import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'shared_components.dart';
import 'card_form.dart';
import 'banned_countries.dart';
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList('cards') ?? [];
    final banned = prefs.getStringList('bannedCountries') ?? [];
    setState(() {
      _cards = cardsJson.map((e) => CreditCard.fromJson(jsonDecode(e))).toList();
      _bannedCountries = banned;
    });
  }

  Future<void> _saveCards(List<CreditCard> cards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('cards', cards.map((c) => jsonEncode(c.toJson())).toList());
  }

  Future<void> _saveBannedCountries(List<String> countries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bannedCountries', countries);
  }

  void _addCard(CreditCard card) {
    setState(() {
      _cards.add(card);
    });
    _saveCards(_cards);
  }

  void _updateBannedCountries(List<String> countries) {
    setState(() {
      _bannedCountries = countries;
    });
    _saveBannedCountries(countries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Card Validation'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardForm(
              bannedCountries: _bannedCountries,
              onCardAdded: _addCard,
              existingCards: _cards,
            ),
            const SizedBox(height: 24),
            BannedCountriesWidget(
              bannedCountries: _bannedCountries,
              onChanged: _updateBannedCountries,
            ),
            const SizedBox(height: 24),
            Text('Captured Cards:', style: Theme.of(context).textTheme.titleMedium),
            ..._cards.map((c) => CardDisplay(
                  number: c.number,
                  type: c.type,
                  country: c.issuingCountry,
                )),
          ],
        ),
      ),
    );
  }
}
