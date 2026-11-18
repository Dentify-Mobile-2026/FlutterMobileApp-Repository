
import 'package:flutter/material.dart';

class GlassmorphicCard extends StatefulWidget {
  final Widget child;
  final String title;
  final IconData icon;
  final Color contentColor;

  const GlassmorphicCard({
    required this.child,
    required this.title,
    required this.icon,
    required this.contentColor,
    super.key,
  });

  @override
  _GlassmorphicCardState createState() => _GlassmorphicCardState();
}

class _GlassmorphicCardState extends State<GlassmorphicCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween(begin: 1.0, end: 0.97).animate(_ctrl);
  }

  void _onPress(bool down) {
    if (down) _ctrl.forward();
    else _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),
      onTapDown: (_) => _onPress(true),
      onTapUp: (_) => _onPress(false),
      onTapCancel: () => _onPress(false),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white.withOpacity(0.1),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(widget.icon, color: widget.contentColor, size: 32),
                      const SizedBox(width: 16),
                      Text(widget.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: 16),
                    widget.child,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
