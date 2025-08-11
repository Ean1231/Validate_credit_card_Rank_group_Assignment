import 'dart:async';
import 'package:flutter/material.dart';
import 'package:credit_card_scanner/credit_card_scanner.dart';

import '../../models.dart';
import '../../services/country_service.dart';

class CardForm extends StatefulWidget {
  final List<String> bannedCountries;
  final List<CreditCard> existingCards;
  final void Function(CreditCard card) onCardAdded;
  final void Function(CreditCard card)? onCardChanged;

  const CardForm({
    super.key,
    required this.bannedCountries,
    required this.existingCards,
    required this.onCardAdded,
    this.onCardChanged,
  });

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _expiryDateController;
  late TextEditingController _cardHolderNameController;

  String _cardType = '';
  String _cvv = '';
  String _issuingCountry = '';

  List<CountryInfo> _countries = [];
  List<CountryInfo> _filtered = [];
  bool _loadingCountries = true;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryDateController = TextEditingController();
    _cardHolderNameController = TextEditingController();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final list = await CountryService.fetchAll();
      setState(() {
        _countries = list;
        _filtered = list;
        _loadingCountries = false;
      });
    } catch (_) {
      setState(() => _loadingCountries = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load countries')));
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  String detectCardType(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.startsWith('4')) return 'visa';
    if (clean.startsWith('5')) return 'mastercard';
    if (clean.startsWith('34') || clean.startsWith('37')) return 'american express';
    if (clean.startsWith('6')) return 'discover';
    return 'unknown';
  }

  void _notifyCardChanged() {
    if (widget.onCardChanged != null) {
      final card = CreditCard(
        number: _cardNumberController.text,
        type: detectCardType(_cardNumberController.text),
        cvv: _cvv,
        issuingCountry: _issuingCountry,
        expiryDate: _expiryDateController.text,
        cardHolderName: _cardHolderNameController.text,
        country: '',
      );
      widget.onCardChanged!(card);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newCard = CreditCard(
        number: _cardNumberController.text,
        type: detectCardType(_cardNumberController.text),
        cvv: _cvv,
        issuingCountry: _issuingCountry,
        expiryDate: _expiryDateController.text,
        cardHolderName: _cardHolderNameController.text,
        country: '',
      );
      final exists = widget.existingCards.any((c) => c.number == newCard.number);
      if (!exists) {
        widget.onCardAdded(newCard);
        _formKey.currentState?.reset();
        setState(() {
          _cardNumberController.clear();
          _expiryDateController.clear();
          _cardHolderNameController.clear();
          _cardType = '';
          _cvv = '';
          _issuingCountry = '';
        });
        _notifyCardChanged();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card already exists')));
      }
    }
  }

  Future<void> _scanCard() async {
    final result = await CardScanner.scanCard(
      scanOptions: const CardScanOptions(scanCardHolderName: true, scanExpiryDate: true),
    );
    if (result != null && result.cardNumber.isNotEmpty) {
      setState(() {
        _cardNumberController.text = result.cardNumber;
        _expiryDateController.text = result.expiryDate ?? '';
        _cardHolderNameController.text = result.cardHolderName ?? '';
        _cardType = detectCardType(result.cardNumber);
      });
      _notifyCardChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No card detected')));
    }
  }

  void _openCountryPicker() async {
    if (_loadingCountries) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final searchController = TextEditingController();
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: StatefulBuilder(
                builder: (context, setSheetState) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search country', border: OutlineInputBorder()),
                              onChanged: (text) {
                                final q = text.toLowerCase();
                                setSheetState(() {
                                  _filtered = _countries.where((c) => c.name.toLowerCase().contains(q)).toList();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = _filtered[index];
                          return ListTile(
                            leading: Text(c.flagEmoji, style: const TextStyle(fontSize: 24)),
                            title: Text(c.name),
                            onTap: () {
                              setState(() => _issuingCountry = c.name);
                              _notifyCardChanged();
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _cardHolderNameController,
            decoration: const InputDecoration(labelText: 'Card Holder Name'),
            onChanged: (val) => _notifyCardChanged(),
            validator: (val) => val == null || val.isEmpty ? 'Enter card holder name' : null,
          ),
          TextFormField(
            controller: _cardNumberController,
            decoration: const InputDecoration(labelText: 'Card Number'),
            onChanged: (val) {
              setState(() => _cardType = detectCardType(val));
              _notifyCardChanged();
            },
            validator: (val) => val == null || val.length < 12 ? 'Invalid number' : null,
          ),
          TextFormField(
            controller: _expiryDateController,
            decoration: const InputDecoration(labelText: 'Expiry Date'),
            onChanged: (val) => _notifyCardChanged(),
            validator: (val) => val == null || val.length < 5 ? 'Invalid expiry date' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Issuing Country',
              suffixIcon: _loadingCountries
                  ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                  : IconButton(icon: const Icon(Icons.arrow_drop_down_circle_outlined), onPressed: _openCountryPicker),
            ),
            readOnly: true,
            controller: TextEditingController(text: _issuingCountry),
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter country';
              if (widget.bannedCountries.contains(val)) return 'Country is banned';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'CVV'),
            onChanged: (val) {
              _cvv = val;
              _notifyCardChanged();
            },
            validator: (val) => val == null || val.length < 3 ? 'Invalid CVV' : null,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(onPressed: _scanCard, icon: const Icon(Icons.camera_alt), label: const Text('Scan Card')),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _submit, child: const Text('Submit')),
        ],
      ),
    );
  }
}
