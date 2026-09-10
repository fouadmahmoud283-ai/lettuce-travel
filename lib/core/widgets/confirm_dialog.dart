import 'package:flutter/material.dart';

import 'package:lettuce_travel/core/extensions/context_x.dart';

/// Shows a yes/no confirmation dialog and returns `true` only if the
/// destructive/committing action was confirmed.
///
/// Used for actions that are hard to reverse in the UI (ending a trip,
/// marking a no-show) — never for a plain check-in tap, which must stay a
/// single tap (AGENTS.md section 6).
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  bool isDestructive = false,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(dialogContext.l10n.cancel),
        ),
        FilledButton(
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: dialogContext.colors.error,
                  foregroundColor: dialogContext.colors.onError,
                )
              : null,
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(confirmLabel ?? dialogContext.l10n.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
