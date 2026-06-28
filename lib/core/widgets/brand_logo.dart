import 'package:flutter/material.dart';

class JbsFintechLogo extends StatelessWidget {
  const JbsFintechLogo({super.key, this.height = 92, this.showWordmark = true});

  final double height;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final logoHeight = showWordmark ? height : height * 0.7;

    return Semantics(
      label: 'jbsfintech',
      image: true,
      child: Image.asset(
        'assets/brand/jbsfintech-logo.png',
        height: logoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => JbsFintechWordmark(
          markSize: height * 0.46,
          textSize: height * 0.28,
        ),
      ),
    );
  }
}

class JbsFintechWordmark extends StatelessWidget {
  const JbsFintechWordmark({super.key, this.markSize = 40, this.textSize = 24});

  final double markSize;
  final double textSize;

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF113F72);
    const teal = Color(0xFF149EA4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size.square(markSize),
          painter: _BrandMarkPainter(color: navy),
        ),
        SizedBox(width: markSize * 0.18),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: textSize,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
            children: const [
              TextSpan(
                text: 'jbs',
                style: TextStyle(color: navy),
              ),
              TextSpan(
                text: 'fintech',
                style: TextStyle(color: teal, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandMarkPainter extends CustomPainter {
  const _BrandMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.085
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..color = color;
    final center = Offset(size.width * 0.47, size.height * 0.53);
    final radius = size.width * 0.34;

    canvas.drawCircle(center, radius, stroke);
    canvas.drawLine(
      Offset(size.width * 0.18, size.height * 0.84),
      Offset(size.width * 0.82, size.height * 0.18),
      stroke,
    );

    final arrow = Path()
      ..moveTo(size.width * 0.64, size.height * 0.18)
      ..lineTo(size.width * 0.86, size.height * 0.09)
      ..lineTo(size.width * 0.77, size.height * 0.33)
      ..close();
    canvas.drawPath(arrow, stroke);

    final jbStyle = TextStyle(
      color: color,
      fontSize: size.width * 0.34,
      fontWeight: FontWeight.w900,
      letterSpacing: 0,
    );
    final painter = TextPainter(
      text: TextSpan(text: 'JB', style: jbStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      Offset(
        center.dx - painter.width * 0.52,
        center.dy - painter.height * 0.52,
      ),
    );

    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.84), 2, fill);
  }

  @override
  bool shouldRepaint(covariant _BrandMarkPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
