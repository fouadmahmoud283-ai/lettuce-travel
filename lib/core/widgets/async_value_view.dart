import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';

/// Renders an [AsyncValue] with the app's standard loading and error states,
/// so screens never hand-roll an `isLoading` boolean (AGENTS.md section 6).
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.errorMessage,
    super.key,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;
  final WidgetBuilder? loading;
  final String Function(Object error)? errorMessage;

  @override
  Widget build(BuildContext context) => value.when(
        data: data,
        loading: () =>
            loading?.call(context) ??
            const Center(child: CircularProgressIndicator()),
        error: (Object error, StackTrace stackTrace) => AppErrorView(
          message: errorMessage?.call(error) ?? context.l10n.somethingWrong,
          onRetry: onRetry,
        ),
      );
}

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
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: context.colors.error,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: context.text.bodyLarge,
              ),
              if (onRetry != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: onRetry,
                  child: Text(context.l10n.retry),
                ),
              ],
            ],
          ),
        ),
      );
}

/// Full-bleed empty state, used when a stream resolves to an empty list.
class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    this.message,
    this.icon = Icons.inbox_outlined,
    super.key,
  });

  final String? message;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 40, color: context.colors.outline),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message ?? context.l10n.noData,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.outline),
              ),
            ],
          ),
        ),
      );
}
