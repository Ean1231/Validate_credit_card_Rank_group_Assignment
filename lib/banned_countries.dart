import 'package:flutter/material.dart';

class BannedCountriesWidget extends StatelessWidget {
  final List<String> bannedCountries;
  final void Function(List<String>) onChanged;

  const BannedCountriesWidget({
    super.key,
    required this.bannedCountries,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Banned Countries:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: bannedCountries.map((country) => Chip(
            label: Text(country),
            onDeleted: () {
              final updated = List<String>.from(bannedCountries)..remove(country);
              onChanged(updated);
            },
          )).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Add country'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final newCountry = controller.text.trim();
                if (newCountry.isNotEmpty && !bannedCountries.contains(newCountry)) {
                  final updated = List<String>.from(bannedCountries)..add(newCountry);
                  onChanged(updated);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}