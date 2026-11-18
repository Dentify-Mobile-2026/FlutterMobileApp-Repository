
import 'package:flutter/material.dart';
import 'dart:math';

class CircularStockIndicator extends StatelessWidget {
  final String name;
  final int stock;
  final int maxStock;
  final Color color;

  const CircularStockIndicator({
    required this.name,
    required this.stock,
    required this.maxStock,
    required this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = maxStock > 0 ? stock / maxStock : 0.0;
    return Row(
      children: [
        CustomPaint(
          painter: _CirclePainter(progress, color),
          child: SizedBox(width: 60, height: 60, child: Center(
            child: Text("${(progress * 100).toInt()}%",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          )),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text("$name ($stock/$maxStock)",
            style: const TextStyle(fontSize: 16))),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _CirclePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = 8.0;
    final center = Offset(size.width/2, size.height/2);
    final radius = (size.width - stroke)/2;
    final bg = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, bg);

    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -pi/2, 2*pi*progress, false, fg);
  }

  @override bool shouldRepaint(covariant CustomPainter old) => true;
}
