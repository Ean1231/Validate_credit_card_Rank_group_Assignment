String detectCardType(String number) {
  final clean = number.replaceAll(' ', '');
  if (clean.startsWith('4')) return 'Visa';
  if (clean.startsWith('5')) return 'Mastercard';
  if (clean.startsWith('34') || clean.startsWith('37')) return 'American Express';
  return 'Unknown';
}