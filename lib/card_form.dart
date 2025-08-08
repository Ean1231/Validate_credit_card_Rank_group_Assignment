import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'shared_components.dart';
import 'card_scanner.dart';

class CardForm extends StatefulWidget {
  final List<String> bannedCountries;
  final void Function(CreditCard) onCardAdded;
  final List<CreditCard> existingCards;

  const CardForm({
    super.key,
    required this.bannedCountries,
    required this.onCardAdded,
    required this.existingCards,
  });

  @override
  State<CardForm> createState() => _CardFormState();
}

class _CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();
  String? _selectedCountry;
  String? _error;
  String? _scannedNumber;

  String _inferCardType(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.startsWith('5')) return 'MasterCard';
    if (number.startsWith('3')) return 'American Express';
    if (number.startsWith('6')) return 'Discover';
    return 'Unknown';
  }

  bool _isDuplicate(String number) {
    return widget.existingCards.any((c) => c.number == number);
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    final number = _numberController.text.trim();
    final cvv = _cvvController.text.trim();
    final country = _selectedCountry;
    final type = _inferCardType(number);

    if (country == null) {
      setState(() => _error = 'Please select issuing country.');
      return;
    }
    if (widget.bannedCountries.contains(country)) {
      setState(() => _error = 'This country is banned.');
      return;
    }
    if (_isDuplicate(number)) {
      setState(() => _error = 'This card has already been captured.');
      return;
    }
    final card = CreditCard(
      number: number,
      type: type,
      cvv: cvv,
      issuingCountry: country,
    );
    widget.onCardAdded(card);
    _numberController.clear();
    _cvvController.clear();
    setState(() => _selectedCountry = null);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CardScanner(
            onCardScanned: (number) {
              setState(() {
                _numberController.text = number;
                _scannedNumber = number;
              });
            },
          ),
          const SizedBox(height: 8),
          SharedInputField(
            label: 'Card Number',
            controller: _numberController,
            keyboardType: TextInputType.number,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter card number';
              if (v.length < 12 || v.length > 19) return 'Invalid card number length';
              return null;
            },
          ),
          SharedInputField(
            label: 'CVV',
            controller: _cvvController,
            keyboardType: TextInputType.number,
            obscureText: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Enter CVV';
              if (v.length < 3 || v.length > 4) return 'Invalid CVV';
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(_selectedCountry ?? 'Select Issuing Country'),
                ),
                SharedButton(
                  text: 'Pick Country',
                  isPrimary: false,
                  onPressed: () {
                    showCountryPicker(
                      context: context,
                      showPhoneCode: false,
                      onSelect: (Country c) {
                        setState(() => _selectedCountry = c.name);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          if (_error != null) ErrorMessage(message: _error!),
          SharedButton(
            text: 'Submit',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}