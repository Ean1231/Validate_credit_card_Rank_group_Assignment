import 'dart:convert';
import 'package:http/http.dart' as http;

class CountryInfo {
  final String name;
  final String flagPngUrl;
  final String flagEmoji;

  CountryInfo({required this.name, required this.flagPngUrl, required this.flagEmoji});
}

class CountryService {
  static const _endpoint = 'https://restcountries.com/v3.1/all?fields=name,flags,flag';

  static Future<List<CountryInfo>> fetchAll() async {
    final uri = Uri.parse(_endpoint);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch countries: ${res.statusCode}');
    }
    final List<dynamic> data = jsonDecode(res.body) as List<dynamic>;
    final List<CountryInfo> countries = [];
    for (final item in data) {
      final map = item as Map<String, dynamic>;
      final nameMap = map['name'] as Map<String, dynamic>?;
      final common = (nameMap?['common'] ?? '').toString();
      if (common.isEmpty) continue;
      final flags = map['flags'] as Map<String, dynamic>?;
      final png = (flags?['png'] ?? '').toString();
      final emoji = (map['flag'] ?? '').toString();
      countries.add(CountryInfo(name: common, flagPngUrl: png, flagEmoji: emoji));
    }
    countries.sort((a, b) => a.name.compareTo(b.name));
    return countries;
  }
}
