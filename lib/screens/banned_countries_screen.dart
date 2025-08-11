import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/country_service.dart';

class BannedCountriesScreen extends StatefulWidget {
  final List<String> initial;
  const BannedCountriesScreen({super.key, required this.initial});

  @override
  State<BannedCountriesScreen> createState() => _BannedCountriesScreenState();
}

class _BannedCountriesScreenState extends State<BannedCountriesScreen> {
  late List<String> _banned;
  List<CountryInfo> _countries = [];
  List<CountryInfo> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _banned = List<String>.from(widget.initial);
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final list = await CountryService.fetchAll();
      setState(() {
        _countries = list;
        _filtered = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to load countries')));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bannedCountries', _banned);
  }

  void _openPicker() {
    if (_loading) return;
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
                builder: (context, setSheet) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search country', border: OutlineInputBorder()),
                        onChanged: (text) {
                          final q = text.toLowerCase();
                          setSheet(() => _filtered = _countries.where((c) => c.name.toLowerCase().contains(q)).toList());
                        },
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final c = _filtered[index];
                          final isBanned = _banned.contains(c.name);
                          return ListTile(
                            leading: Text(c.flagEmoji, style: const TextStyle(fontSize: 24)),
                            title: Text(c.name),
                            trailing: isBanned ? const Icon(Icons.check, color: Colors.red) : null,
                            onTap: () async {
                              setState(() {
                                if (isBanned) {
                                  _banned.remove(c.name);
                                } else {
                                  _banned.add(c.name);
                                }
                              });
                              await _save();
                              if (mounted) Navigator.pop(context);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banned Countries'),
        actions: [TextButton(onPressed: () => Navigator.pop(context, _banned), child: const Text('Done'))],
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: _openPicker, icon: const Icon(Icons.public), label: const Text('Add/Remove')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _banned.isEmpty
              ? const Center(child: Text('No banned countries'))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _banned.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final name = _banned[index];
                    return ListTile(
                      title: Text(name),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          setState(() => _banned.removeAt(index));
                          await _save();
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
