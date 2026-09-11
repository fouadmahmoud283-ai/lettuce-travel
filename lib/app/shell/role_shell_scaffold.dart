import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lettuce_travel/app/theme/app_colors.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/widgets/glass_surface.dart';

/// One destination in a [RoleShellScaffold]'s floating bottom nav.
class ShellDestination {
  const ShellDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// A small count badge (e.g. open incidents), or null / zero to hide it.
  final int? badgeCount;
}

/// The persistent shell wrapping each role's tab set.
///
/// Renders the active branch full-bleed behind a floating, frosted-glass pill
/// navigation bar — the "feels like a real app" structural change: sub-screens
/// still push on top and hide this bar entirely, but the three or four main
/// sections of a role are always one tap away.
///
/// Built once and parameterised by [destinations] + [navigationShell], so
/// `app_router.dart` stays the only place that decides what each role's tabs
/// actually are.
class RoleShellScaffold extends StatelessWidget {
  const RoleShellScaffold({
    required this.navigationShell,
    required this.destinations,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final List<ShellDestination> destinations;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: _FloatingGlassNav(
            currentIndex: navigationShell.currentIndex,
            destinations: destinations,
            onTap: (int index) => navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            ),
          ),
        ),
      );
}

class _FloatingGlassNav extends StatelessWidget {
  const _FloatingGlassNav({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  final int currentIndex;
  final List<ShellDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 66,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 4),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.meshTeal.withValues(alpha: 0.28),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg + 4),
          blurSigma: 22,
          tintOpacity: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.75,
          tintColor: Theme.of(context).colorScheme.surface,
          borderOpacity: 0.6,
          child: Row(
            children: <Widget>[
              for (int i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavItem(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final ShellDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int? badge = destination.badgeCount;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                gradient: selected
                    ? const LinearGradient(
                        colors: <Color>[AppColors.meshTeal, AppColors.primary],
                      )
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Icon(
                    selected ? destination.selectedIcon : destination.icon,
                    color: selected ? Colors.white : scheme.onSurfaceVariant,
                    size: 22,
                  ),
                  if (badge != null && badge > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        constraints: const BoxConstraints(minWidth: 14),
                        decoration: BoxDecoration(
                          color: scheme.error,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: scheme.surface, width: 1.5),
                        ),
                        child: Text(
                          '$badge',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: scheme.onError,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? scheme.primary : scheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
