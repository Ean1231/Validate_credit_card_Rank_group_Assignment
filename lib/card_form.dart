import 'package:flutter/material.dart';
import 'package:credit_card_scanner/credit_card_scanner.dart';

import 'models.dart';

class CardForm extends StatefulWidget {
  final List<String> bannedCountries;
  final List<CreditCard> existingCards;
  final void Function(CreditCard card) onCardAdded;

  // New callback for live card updates
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
  late TextEditingController _cardHolderNameController;  // new controller

  String _cardType = '';
  String _cvv = '';
  String _country = '';

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _expiryDateController = TextEditingController();
    _cardHolderNameController = TextEditingController();  // init
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cardHolderNameController.dispose();  // dispose
    super.dispose();
  }

  String detectCardType(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.startsWith('4')) return 'Visa';
    if (clean.startsWith('5')) return 'Mastercard';
    if (clean.startsWith('34') || clean.startsWith('37')) return 'American Express';
    return 'Unknown';
  }

  void _notifyCardChanged() {
    if (widget.onCardChanged != null) {
      final card = CreditCard(
        number: _cardNumberController.text,
        type: detectCardType(_cardNumberController.text),
        cvv: _cvv,
        country: _country,
        issuingCountry: '',
        expiryDate: _expiryDateController.text,
        cardHolderName: _cardHolderNameController.text,  // pass name
      );
      widget.onCardChanged!(card);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final newCard = CreditCard(
        number: _cardNumberController.text,
        type: _cardType,
        cvv: _cvv,
        country: _country,
        issuingCountry: '',
        expiryDate: _expiryDateController.text,
        cardHolderName: _cardHolderNameController.text,  // pass name
      );

      final exists = widget.existingCards.any((c) => c.number == newCard.number);
      if (!exists) {
        widget.onCardAdded(newCard);
        _formKey.currentState?.reset();
        setState(() {
          _cardNumberController.clear();
          _expiryDateController.clear();
          _cardHolderNameController.clear();  // clear name
          _cardType = '';
          _cvv = '';
          _country = '';
        });
        _notifyCardChanged(); // clear live preview after submit
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Card already exists')),
        );
      }
    }
  }

  Future<void> _scanCard() async {
    final result = await CardScanner.scanCard(
      scanOptions: const CardScanOptions(
        scanCardHolderName: true,  // scan name as well
        scanExpiryDate: true,
      ),
    );

    if (result != null && result.cardNumber.isNotEmpty) {
      setState(() {
        _cardNumberController.text = result.cardNumber;
        _expiryDateController.text = result.expiryDate ?? '';
        _cardHolderNameController.text = result.cardHolderName ?? '';  // set name
        _cardType = detectCardType(result.cardNumber);
      });
      _notifyCardChanged();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No card detected')),
      );
    }
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
              setState(() {
                _cardType = detectCardType(val);
              });
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
            decoration: const InputDecoration(labelText: 'CVV'),
            onChanged: (val) {
              _cvv = val;
              _notifyCardChanged();
            },
            validator: (val) => val == null || val.length < 3 ? 'Invalid CVV' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Issuing Country'),
            onChanged: (val) {
              _country = val;
              _notifyCardChanged();
            },
            validator: (val) {
              if (val == null || val.isEmpty) return 'Enter country';
              if (widget.bannedCountries.contains(val)) return 'Country is banned';
              return null;
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _scanCard,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Card'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _submit,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
