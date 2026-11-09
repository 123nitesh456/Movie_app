import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

/// Centered spinner shown while data is loading.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.accent),
    );
  }
}
