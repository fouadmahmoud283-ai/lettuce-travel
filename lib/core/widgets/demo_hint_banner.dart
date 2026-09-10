import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';

/// A small tinted callout used on the sign-in screens to surface the
/// demo-repository hints (which phone number / password signs in as which
/// role) as a designed affordance rather than leftover debug text.
///
/// Delete this once real Firebase phone auth replaces `FakeAuthRepository`
/// (see docs/roadmap.md M1) — every call site goes with it.
class DemoHintBanner extends StatelessWidget {
  const DemoHintBanner({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.info_outline_rounded, size: 16, color: context.colors.onSecondaryContainer),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  text,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSecondaryContainer),
                ),
              ),
            ],
          ),
        ),
      );
}
