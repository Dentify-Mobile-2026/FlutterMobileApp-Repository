import 'package:flutter/material.dart';
import 'dart:ui';

class SparklinePayments extends StatefulWidget {
  final List<double> payments;
  final Color color;

  const SparklinePayments({required this.payments, required this.color, super.key});

  @override
  _SparklinePaymentsState createState() => _SparklinePaymentsState();
}

class _SparklinePaymentsState extends State<SparklinePayments> {
  int hovered = -1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (evt) {
        if (widget.payments.isEmpty) return;
        final w = context.size!.width;
        final idx = (evt.localPosition.dx / (w / (widget.payments.length + 1))).floor() - 1;
        setState(() => hovered = idx >= 0 && idx < widget.payments.length ? idx : -1);
      },
      child: CustomPaint(
        size: Size(double.infinity, 80),
        painter: _SparkPainter(widget.payments, widget.color, hovered),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final int hovered;
  _SparkPainter(this.data, this.color, this.hovered);

 @override
void paint(Canvas c, Size size) {
  if (data.isEmpty) return;
  final maxv = data.reduce((a, b) => a > b ? a : b);
  final norm = data.map((e) => e / maxv).toList();
  final path = Path();
  final dotPaint = Paint()..color = color;
  final linePaint = Paint()
    ..color = color.withOpacity(0.4)
    ..strokeWidth = 2;

  final spacing = size.width / (data.length + 1);

  for (var i = 0; i < norm.length; i++) {
    final x = spacing * (i + 1);
    final y = size.height * (1 - norm[i]);

    if (i == 0) {
      path.moveTo(x, y);
    } else {
      path.lineTo(x, y);
    }

    c.drawCircle(
      Offset(x, y),
      i == hovered ? 10.0 : 6.0,
      dotPaint..color = color.withOpacity(i == hovered ? 1.0 : 0.8),
    );
  }

  c.drawPath(path, linePaint);
}


  @override bool shouldRepaint(covariant CustomPainter old) => true;
}
