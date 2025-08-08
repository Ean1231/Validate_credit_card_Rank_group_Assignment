import 'package:flutter/material.dart';
// Alias the plugin import so we can still call CardScanner from the package
import 'package:credit_card_scanner/credit_card_scanner.dart' as card_scanner_pkg;

import 'shared_components.dart';

class CardScanner extends StatefulWidget {
  final void Function(String number) onCardScanned;
  const CardScanner({super.key, required this.onCardScanned});

  @override
  State<CardScanner> createState() => _CardScannerState();
}

class _CardScannerState extends State<CardScanner> {
  bool _scanning = false;
  String? _error;

  Future<void> _scanCard() async {
    setState(() {
      _scanning = true;
      _error = null;
    });
    try {
      final result = await card_scanner_pkg.CardScanner.scanCard(
        scanOptions: const card_scanner_pkg.CardScanOptions(
          scanCardHolderName: false,
          scanExpiryDate: false,
        ),
      );
      if (result != null && result.cardNumber.isNotEmpty) {
        widget.onCardScanned(result.cardNumber);
      } else {
        setState(() => _error = 'No card detected.');
      }
    } catch (e) {
      setState(() => _error = 'Failed to scan card.');
    } finally {
      setState(() => _scanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
          SharedButton(
          text: _scanning ? 'Scanning...' : 'Scan Card', // null disables the button
          onPressed: _scanning ? () {} : _scanCard,
        ),
        if (_error != null) ErrorMessage(message: _error!),
      ],
    );
  }
}
