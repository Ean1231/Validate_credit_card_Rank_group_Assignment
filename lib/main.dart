import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';
import 'features/card_form/card_form.dart';
import 'widgets/card_display/styled_card_display.dart';
import 'screens/saved_cards_screen.dart';
import 'screens/banned_countries_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CreditCardApp());
}

class CreditCardApp extends StatelessWidget {
  const CreditCardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Credit Card Validation1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
