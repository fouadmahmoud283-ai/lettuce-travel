import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/shimmer_skeleton.dart';

/// Renders an [AsyncValue] with the app's standard loading and error states,
/// so screens never hand-roll an `isLoading` boolean (AGENTS.md section 6).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.errorMessage,
    this.skeletonKind,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final WidgetBuilder? loading;
  final String Function(Object error)? errorMessage;

  /// Opt-in shimmer skeleton for screens whose loading state is actually
  /// visible for a moment (a list or a hero card) rather than instant —
  /// leave null for the plain spinner, which is fine for quick taps.
  final SkeletonKind? skeletonKind;

  @override
  Widget build(BuildContext context) => value.when(
        data: data,
        loading: () => loading?.call(context) ?? _defaultLoading(),
        error: (Object error, StackTrace stackTrace) => AppErrorView(
          message: errorMessage?.call(error) ?? context.l10n.somethingWrong,
          onRetry: onRetry,
        ),
      );

  Widget _defaultLoading() => switch (skeletonKind) {
        null => const Center(child: CircularProgressIndicator()),
        SkeletonKind.list => const ShimmerListSkeleton(),
        SkeletonKind.card => const ShimmerCardSkeleton(),
      };
}

/// Which shimmer shape [AsyncValueView] should show while loading, when
/// [AsyncValueView.skeletonKind] is set.
enum SkeletonKind { list, card }

/// Full-bleed error state with an optional retry action.
class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.message, this.onRetry, super.key});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.errorContainer,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 32,
                  color: context.colors.onErrorContainer,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyLarge,
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: onRetry,
                  label: Text(context.l10n.retry),
                ),
              ],
            ],
          ),
        ),
      );
}

/// Full-bleed empty state, used when a stream resolves to an empty list.
///
/// The icon sits inside a soft tinted circle rather than floating bare — a
/// small touch, but it is what separates a polished empty state from a
/// "nothing to see, sorry" placeholder, and it repeats identically across
/// every list screen in the app.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    super.key,
  });

  final String? message;
  final IconData icon;

  /// An optional call to action shown under the message, e.g. "Add a school".
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.surfaceContainerHighest,
                ),
                child: Icon(icon, size: 32, color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                message ?? context.l10n.noData,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              if (action != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                action!,
              ],
            ],
          ),
        ),
      );
}
