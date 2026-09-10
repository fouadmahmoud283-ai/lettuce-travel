import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// A tappable card used for section navigation grids (the admin dashboard).
///
/// Scales down slightly on press — a small tactile cue that the whole card is
/// the tap target, not just the icon or label inside it.
class NavCard extends StatefulWidget {
  const NavCard({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badgeCount,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  State<NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<NavCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: scheme.surface,
        elevation: 1,
        shadowColor: scheme.shadow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(widget.icon, color: scheme.onPrimaryContainer, size: 22),
                      ),
                    ),
                    if (widget.badgeCount != null && widget.badgeCount! > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: scheme.error,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                        child: Text(
                          '${widget.badgeCount}',
                          style: TextStyle(
                            color: scheme.onError,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
