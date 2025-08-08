// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:validate_credit_card/main.dart';
import 'package:validate_credit_card/models.dart';

void main() {
  testWidgets('Credit Card Form renders and validates', (WidgetTester tester) async {
    await tester.pumpWidget(const CreditCardApp());
    expect(find.text('Credit Card Validation'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Enter card number'), findsOneWidget);
    expect(find.text('Enter CVV'), findsOneWidget);
  });

  test('CreditCard model serializes and deserializes', () {
    final card = CreditCard(number: '4111111111111111', type: 'Visa', cvv: '123', issuingCountry: 'United States');
    final json = card.toJson();
    final fromJson = CreditCard.fromJson(json);
    expect(fromJson.number, card.number);
    expect(fromJson.type, card.type);
    expect(fromJson.cvv, card.cvv);
    expect(fromJson.issuingCountry, card.issuingCountry);
  });
}
