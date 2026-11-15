import 'package:flutter/material.dart';

/// Crisp, pixel-perfect ABA Bank brand logo widget.
///
/// Features the signature ABA deep navy teal (#005E7C), bold white lettering,
/// and the distinctive red accent mark (#E31837).
class AbaLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;

  const AbaLogo({
    super.key,
    this.size = 44,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? (size * 0.22);
    final scale = size / 44.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF005E7C),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF005E7C).withValues(alpha: 0.28),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Lettering with signature red accent scaled cleanly without overflow
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'ABA',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16.5 * scale,
                          letterSpacing: 0.8 * scale,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 2.5 * scale),
                      Transform.translate(
                        offset: Offset(0, -6.5 * scale),
                        child: Container(
                          width: 3.5 * scale,
                          height: 7.5 * scale,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE31837),
                            borderRadius: BorderRadius.circular(1 * scale),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
