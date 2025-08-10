import 'package:flutter/material.dart';
import 'package:credit_card_scanner/credit_card_scanner.dart';

class CardScanButton extends StatefulWidget {
  final void Function(CardDetails result) onCardScanned;

  const CardScanButton({super.key, required this.onCardScanned});

  @override
  State<CardScanButton> createState() => _CardScanButtonState();
}

class _CardScanButtonState extends State<CardScanButton> {
  bool _scanning = false;
  String? _error;

  Future<void> _scanCard() async {
    setState(() {
      _scanning = true;
      _error = null;
    });

    try {
      final result = await CardScanner.scanCard(
        scanOptions: const CardScanOptions(
          scanCardHolderName: false,
          scanExpiryDate: true,
        ),
      );

      if (result != null && result.cardNumber.isNotEmpty) {
        widget.onCardScanned(result);
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
        ElevatedButton.icon(
          onPressed: _scanning ? null : _scanCard,
          icon: const Icon(Icons.camera_alt),
          label: Text(_scanning ? 'Scanning...' : 'Scan Card'),
        ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}