import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/localization/locale_controller.dart';
import 'package:lettuce_travel/app/router/route_paths.dart';
import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/bus_illustration.dart';
import 'package:lettuce_travel/core/widgets/glass_surface.dart';

/// The very first screen a signed-out user sees, after the splash screen
/// resolves that there is no session. Its only job is to point the user at
/// the right sign-in path — parent/supervisor (phone OTP) or administrator
/// (email) — before they've committed to either.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // --- Hero photo, top ~46% of the screen, fading into the page
          // background so the button area below never sits on top of it. ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: context.screenSize.height * 0.46,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Image.asset(
                  'assets/images/bus_hero.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const BusIllustration(height: double.infinity),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        Colors.black.withValues(alpha: 0.15),
                        Colors.black.withValues(alpha: 0.05),
                        context.theme.scaffoldBackgroundColor,
                      ],
                      stops: const <double>[0, 0.55, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: <Widget>[
                  Align(
                    alignment: AlignmentDirectional.topEnd,
                    child: GlassSurface(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      blurSigma: 10,
                      tintColor: Colors.white,
                      tintOpacity: 0.28,
                      padding: EdgeInsets.zero,
                      child: IconButton(
                        icon: const Icon(Icons.language_rounded, color: Colors.white),
                        tooltip: context.l10n.language,
                        onPressed: () => ref.read(localeControllerProvider.notifier).toggle(),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    context.l10n.welcomeTitle,
                    style: context.text.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.12, end: 0),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    context.l10n.welcomeTagline,
                    style: context.text.bodyLarge
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 100.ms, duration: 420.ms),
                  const SizedBox(height: AppSpacing.lg),
                  const _RoleStrip().animate().fadeIn(delay: 180.ms, duration: 420.ms),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => context.push(RoutePaths.phoneSignIn),
                      child: Text(context.l10n.getStarted),
                    ),
                  ).animate().fadeIn(delay: 260.ms, duration: 380.ms).slideY(begin: 0.15, end: 0),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: () => context.push(RoutePaths.adminSignIn),
                    child: Text(context.l10n.adminSignIn),
                  ).animate().fadeIn(delay: 320.ms, duration: 380.ms),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Who this app is for": three small role badges with labels, so a first-time
/// visitor immediately understands the app serves parents, supervisors and
/// school admins from one login screen — not just one of them.
class _RoleStrip extends StatelessWidget {
  const _RoleStrip();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _RoleBadge(
            icon: Icons.family_restroom_rounded,
            label: context.l10n.roleParent,
            color: AppColors.tertiary,
          ),
          const SizedBox(width: AppSpacing.lg),
          _RoleBadge(
            icon: Icons.directions_bus_filled_rounded,
            label: context.l10n.roleSupervisor,
            color: AppColors.secondary,
          ),
          const SizedBox(width: AppSpacing.lg),
          _RoleBadge(
            icon: Icons.admin_panel_settings_rounded,
            label: context.l10n.roleSuperAdmin,
            color: AppColors.primary,
          ),
        ],
      );
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ],
      );
}
