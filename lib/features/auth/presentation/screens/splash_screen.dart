import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/widgets/app_logo_mark.dart';

/// Shown while the session is being resolved on cold start.
///
/// The first thing every user sees, so it carries the brand gradient used
/// throughout the app (see `GradientHeroHeader`) rather than a bare white
/// screen — a returning parent or supervisor should recognise the product in
/// the half-second before the router redirects them into their role.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const AppBrandSplash(title: 'Lettuce Travel'),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
