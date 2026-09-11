import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// A shimmering placeholder list, shown while a screen's real data is still
/// loading — replaces a bare spinner on the screens where the loading state
/// is actually visible for a moment (list-shaped content, not instant taps).
///
/// [shimmer] has been a dependency since the original scaffold but was never
/// wired up; this is the first real use of it.
class ShimmerListSkeleton extends StatelessWidget {
  const ShimmerListSkeleton({
    this.itemCount = 5,
    this.itemHeight = 76,
    super.key,
  });

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (BuildContext context, int index) => Container(
          height: itemHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              CircleAvatar(radius: itemHeight * 0.32, backgroundColor: Colors.white),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(width: double.infinity, height: 14, color: Colors.white),
                    const SizedBox(height: AppSpacing.sm),
                    Container(width: 120, height: 12, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shimmering placeholder for a single hero-card-shaped block (used where a
/// screen's loading state is one big card rather than a list).
class ShimmerCardSkeleton extends StatelessWidget {
  const ShimmerCardSkeleton({this.height = 160, super.key});

  final double height;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: scheme.surfaceContainerHighest,
      highlightColor: scheme.surface,
      child: Container(
        height: height,
        margin: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }
}
