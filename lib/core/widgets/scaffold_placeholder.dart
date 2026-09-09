import 'package:flutter/material.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';

/// Temporary screen body used by scaffolded screens that have no real UI yet.
///
/// Every use of this widget is a piece of work still to do; grep for it to find
/// what remains. Delete the widget once nothing references it.
class ScaffoldPlaceholder extends StatelessWidget {
  const ScaffoldPlaceholder({
    required this.title,
    required this.description,
    this.todo = const <String>[],
    super.key,
  });

  final String title;
  final String description;
  final List<String> todo;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            Text(description, style: theme.textTheme.bodyLarge),
            if (todo.isNotEmpty) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text('Still to build', style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              for (final String item in todo)
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    bottom: AppSpacing.sm,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(Icons.check_box_outline_blank, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
