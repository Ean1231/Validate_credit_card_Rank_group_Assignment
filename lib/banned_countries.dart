import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_components.dart';

class BannedCountriesWidget extends StatefulWidget {
  final List<String> bannedCountries;
  final void Function(List<String>) onChanged;

  const BannedCountriesWidget({
    super.key,
    required this.bannedCountries,
    required this.onChanged,
  });

  @override
  State<BannedCountriesWidget> createState() => _BannedCountriesWidgetState();
}

class _BannedCountriesWidgetState extends State<BannedCountriesWidget> {
  final _controller = TextEditingController();

  void _addCountry() {
    final country = _controller.text.trim();
    if (country.isNotEmpty && !widget.bannedCountries.contains(country)) {
      final updated = List<String>.from(widget.bannedCountries)..add(country);
      widget.onChanged(updated);
      _controller.clear();
    }
  }

  void _removeCountry(String country) {
    final updated = List<String>.from(widget.bannedCountries)..remove(country);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SharedInputField(
                label: 'Add Banned Country',
                controller: _controller,
              ),
            ),
            SharedButton(
              text: 'Add',
              onPressed: _addCountry,
              isPrimary: false,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text('Banned Countries:', style: Theme.of(context).textTheme.titleMedium),
        ...widget.bannedCountries.map((country) => ListTile(
              title: Text(country),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeCountry(country),
              ),
            )),
      ],
    );
  }
}