import 'package:dentify_flutter/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          gradient: const LinearGradient(
            colors: [
              AppColors.surface,
              AppColors.surfaceSubtle,
            ],
            begin: Alignment(-1, 0),
            end: Alignment(1, 0),
          ),
        ),
      ),
    );
  }
}
