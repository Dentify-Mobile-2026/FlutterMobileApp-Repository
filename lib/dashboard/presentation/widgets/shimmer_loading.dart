import 'package:flutter/material.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.blueGrey.withOpacity(0.3),
              Colors.grey.withOpacity(0.3),
            ],
            begin: Alignment(-1, 0),
            end: Alignment(1, 0),
          ),
        ),
      ),
    );
  }
}
