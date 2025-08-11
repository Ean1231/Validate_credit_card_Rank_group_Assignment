import 'package:flutter/material.dart';
import 'dart:ui';

class StyledCardDisplay extends StatelessWidget {
  final String number;
  final String type;
  final String country;
  final String expiryDate;
  final String cardHolderName;

  const StyledCardDisplay({
    super.key,
    required this.number,
    required this.type,
    required this.country,
    required this.expiryDate,
    required this.cardHolderName,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedType = type.trim().toLowerCase();
    final spec = _CardThemeSpec.forBrand(normalizedType);

    return AspectRatio(
      aspectRatio: 85.6 / 53.98,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(gradient: spec.background),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(child: spec.buildDecoration()),
              Positioned(
                left: 20,
                right: 20,
                top: 16,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _CardChip(color: spec.foreground.withOpacity(0.85)),
                    const SizedBox(width: 12),
                    Transform.rotate(
                      angle: -1.5708,
                      child: Icon(Icons.wifi, size: 18, color: spec.foreground.withOpacity(0.8)),
                    ),
                    const Spacer(),
                    spec.buildBrandLogo(),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                top: 56,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatNumber(number),
                      style: TextStyle(
                        color: spec.numberColor,
                        fontSize: 22,
                        letterSpacing: 3.0,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      country,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: spec.foreground.withOpacity(0.9), fontSize: 13, letterSpacing: 0.5),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: _LabeledValue(label: 'CARDHOLDER', value: cardHolderName.isEmpty ? 'N/A' : cardHolderName.toUpperCase(), color: spec.foreground),
                    ),
                    const SizedBox(width: 12),
                    _LabeledValue(label: 'VALID THRU', value: expiryDate.isEmpty ? 'MM/YY' : expiryDate, color: spec.foreground, alignEnd: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatNumber(String raw) {
    final clean = raw.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);
      if ((i + 1) % 4 == 0 && i != clean.length - 1) buffer.write(' ');
    }
    return buffer.toString();
  }
}

class _LabeledValue extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool alignEnd;
  const _LabeledValue({required this.label, required this.value, required this.color, this.alignEnd = false});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: color.withOpacity(0.7), fontSize: 9, letterSpacing: 1.1)),
        const SizedBox(height: 2),
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 13, letterSpacing: 0.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CardChip extends StatelessWidget {
  final Color color;
  const _CardChip({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 26,
      decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.6), width: 1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (i) => Container(width: 4, height: 12, decoration: BoxDecoration(color: color.withOpacity(0.6), borderRadius: BorderRadius.circular(2)))),
      ),
    );
  }
}

class _CardThemeSpec {
  final LinearGradient background;
  final Color foreground;
  final Color numberColor;
  final Widget Function() buildBrandLogo;
  final Widget Function() buildDecoration;
  _CardThemeSpec({required this.background, required this.foreground, required this.numberColor, required this.buildBrandLogo, required this.buildDecoration});
  static _CardThemeSpec forBrand(String brand) {
    switch (brand) {
      case 'mastercard':
        return _CardThemeSpec(
          background: const LinearGradient(colors: [Color(0xFF0F2230), Color(0xFF2D3E4A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          foreground: Colors.white,
          numberColor: Colors.white,
          buildBrandLogo: () => Image.network('https://upload.wikimedia.org/wikipedia/commons/0/04/Mastercard-logo.png', height: 30),
          buildDecoration: () => Stack(children: [
                Positioned(right: -40, top: -20, child: _softCircle(const Color(0xFF6A7C88).withOpacity(0.35), 220)),
                Positioned(right: -100, top: 10, child: _softCircle(const Color(0xFF6A7C88).withOpacity(0.25), 280)),
                Positioned(right: 28, bottom: 24, child: _circle(const Color(0xFFEB001B), 44)),
                Positioned(right: 8, bottom: 24, child: _circle(const Color(0xFFF79E1B), 44)),
              ]),
        );
      case 'visa':
        return _CardThemeSpec(
          background: const LinearGradient(colors: [Color(0xFF1A4CA0), Color(0xFF0B7BD4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          foreground: Colors.white,
          numberColor: Colors.white,
          buildBrandLogo: () => Image.network('https://upload.wikimedia.org/wikipedia/commons/5/53/Visa_2014_logo_detail.svg', height: 26),
          buildDecoration: () => Align(
            alignment: Alignment.centerLeft,
            child: Container(margin: const EdgeInsets.only(left: 28), width: 180, height: 120, decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(12))),
          ),
        );
      case 'american express':
      case 'amex':
        return _CardThemeSpec(
          background: const LinearGradient(colors: [Color(0xFF2E77BC), Color(0xFF6FB8E6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          foreground: Colors.white,
          numberColor: Colors.white,
          buildBrandLogo: () => Image.network('https://upload.wikimedia.org/wikipedia/commons/3/30/American_Express_logo_%282018%29.svg', height: 28),
          buildDecoration: () => Align(
            alignment: Alignment.center,
            child: Opacity(
              opacity: 0.08,
              child: const Text('AMERICAN\nEXPRESS', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800, height: 0.95)),
            ),
          ),
        );
      case 'discover':
        return _CardThemeSpec(
          background: const LinearGradient(colors: [Color(0xFF1F1F1F), Color(0xFF3A3A3A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          foreground: Colors.white,
          numberColor: Colors.white,
          buildBrandLogo: () => Image.network('https://upload.wikimedia.org/wikipedia/commons/5/50/Discover_Card_logo.svg', height: 26),
          buildDecoration: () => Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 160,
              height: double.infinity,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0x00FFFFFF), Color(0x22FFFFFF)], begin: Alignment.topLeft, end: Alignment.bottomLeft)),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(width: 110, decoration: const BoxDecoration(color: Color(0xFFFF6000), borderRadius: BorderRadius.only(topLeft: Radius.circular(120), bottomLeft: Radius.circular(120)))),
              ),
            ),
          ),
        );
      default:
        return _CardThemeSpec(
          background: const LinearGradient(colors: [Color(0xFF4E4E4E), Color(0xFF767676)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          foreground: Colors.white,
          numberColor: Colors.white,
          buildBrandLogo: () => const Icon(Icons.credit_card, color: Colors.white70, size: 26),
          buildDecoration: () => const SizedBox.shrink(),
        );
    }
  }
}

Widget _circle(Color color, double size) => Container(width: size, height: size, decoration: BoxDecoration(color: color.withOpacity(0.9), shape: BoxShape.circle));
Widget _softCircle(Color color, double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, Colors.transparent], stops: const [0.0, 1.0])),
    );
