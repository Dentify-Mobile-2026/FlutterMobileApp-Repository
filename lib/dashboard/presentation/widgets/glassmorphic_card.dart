
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
  bool isExpanded = true;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          color: Colors.white,
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
                      Expanded(
                        child: Text(widget.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ),
                      Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: const Color(0xFF64748B)),
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
