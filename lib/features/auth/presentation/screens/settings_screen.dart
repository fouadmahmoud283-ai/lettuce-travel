import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/localization/locale_controller.dart';
import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/widgets/confirm_dialog.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';

/// Shared across all three roles: language and sign-out. Reachable from any
/// role's home screen (see the redirect-guard exception in app_router.dart).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthState auth = ref.watch(authControllerProvider);
    final Locale locale = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            if (auth.user != null)
              Card(
                color: context.colors.surface,
                elevation: 1,
                shadowColor: context.colors.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: context.colors.primaryContainer,
                    foregroundColor: context.colors.onPrimaryContainer,
                    child: const Icon(Icons.person_outline),
                  ),
                  title: Text(auth.user!.displayName),
                  subtitle: Text(auth.user!.phone ?? auth.user!.email ?? ''),
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Card(
              color: context.colors.surface,
              elevation: 1,
              shadowColor: context.colors.shadow.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: context.colors.secondaryContainer,
                  foregroundColor: context.colors.onSecondaryContainer,
                  child: const Icon(Icons.language_rounded),
                ),
                title: Text(context.l10n.language),
                trailing: SegmentedButton<String>(
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(value: 'ar', label: Text('عربي')),
                    ButtonSegment<String>(value: 'en', label: Text('English')),
                  ],
                  selected: <String>{locale.languageCode},
                  onSelectionChanged: (Set<String> selected) => ref
                      .read(localeControllerProvider.notifier)
                      .setLocale(Locale(selected.first)),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded),
              label: Text(context.l10n.signOut),
              onPressed: () => unawaited(_signOut(context, ref)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: context.l10n.signOutConfirmTitle,
      message: context.l10n.signOutConfirmMessage,
      confirmLabel: context.l10n.signOut,
      isDestructive: true,
    );
    if (!confirmed) return;
    await ref.read(authControllerProvider.notifier).signOut();
  }
}
