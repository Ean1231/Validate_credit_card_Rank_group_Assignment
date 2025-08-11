String detectCardType(String cardNumber) {
  final digits = cardNumber.replaceAll(RegExp(r'\s+'), '');
  if (digits.isEmpty) return 'unknown';

  if (digits.startsWith('4')) return 'visa';

  if (digits.startsWith('34') || digits.startsWith('37')) return 'american express';

  if (digits.startsWith('6')) return 'discover';

  if (_isMastercard(digits)) return 'mastercard';

  return 'unknown';
}

bool _isMastercard(String digits) {
  if (digits.length < 2) return false;
  final two = int.tryParse(digits.substring(0, 2)) ?? -1;
  if (two >= 51 && two <= 55) return true;
  if (digits.length >= 4) {
    final four = int.tryParse(digits.substring(0, 4)) ?? -1;
    if (four >= 2221 && four <= 2720) return true;
  }
  return false;
}
