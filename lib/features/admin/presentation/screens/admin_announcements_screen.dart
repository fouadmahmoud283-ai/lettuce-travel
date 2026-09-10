import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/core/widgets/status_chip.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/messaging/data/repositories/fake_announcement_repository.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/announcement.dart';
import 'package:lettuce_travel/features/schools/data/repositories/fake_bus_route_repository.dart';
import 'package:lettuce_travel/features/schools/domain/entities/bus_route.dart';

class AdminAnnouncementsScreen extends ConsumerWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Announcement>> announcements =
        ref.watch(_announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.announcements)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          showDragHandle: true,
          builder: (_) => const _ComposeSheet(),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Align(
          alignment: AlignmentDirectional.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: AsyncValueView<List<Announcement>>(
              value: announcements,
              data: (List<Announcement> items) {
                if (items.isEmpty) {
                  return AppEmptyView(message: context.l10n.announcementsEmpty, icon: Icons.campaign_outlined);
                }
                final List<Announcement> sorted = List<Announcement>.of(items)
                  ..sort(
                    (Announcement a, Announcement b) =>
                        (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
                  );
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  itemCount: sorted.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (BuildContext context, int index) {
                    final Announcement a = sorted[index];
                    final bool routeScoped = a.scope == AnnouncementScope.route;
                    return Material(
                      color: context.colors.surface,
                      elevation: 2,
                      shadowColor: context.colors.shadow.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      clipBehavior: Clip.antiAlias,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(width: 5, color: routeScoped ? context.colors.secondary : context.colors.primary),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Icon(
                                          routeScoped ? Icons.alt_route_rounded : Icons.campaign_rounded,
                                          color: routeScoped ? context.colors.secondary : context.colors.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Text(
                                            a.title,
                                            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        StatusChip(
                                          label: routeScoped
                                              ? context.l10n.announcementScopeRoute
                                              : context.l10n.announcementScopeSchool,
                                          color: routeScoped ? context.colors.secondary : context.colors.primary,
                                          dense: true,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(a.body, style: context.text.bodyMedium),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      a.createdAt == null
                                          ? ''
                                          : a.createdAt!.toClockTime(context.l10n.localeName),
                                      style: context.text.labelMedium?.copyWith(
                                        color: context.colors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

final StreamProvider<List<Announcement>> _announcementsProvider =
    StreamProvider<List<Announcement>>(
  (Ref ref) => ref.watch(announcementRepositoryProvider).watchSchoolAnnouncements(MockIds.schoolId),
);

final StreamProvider<List<BusRoute>> _routesForAnnouncementsProvider =
    StreamProvider<List<BusRoute>>(
  (Ref ref) => ref.watch(busRouteRepositoryProvider).watchSchoolRoutes(MockIds.schoolId),
);

class _ComposeSheet extends ConsumerStatefulWidget {
  const _ComposeSheet();

  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _body = TextEditingController();
  AnnouncementScope _scope = AnnouncementScope.school;
  String? _routeId;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<BusRoute>> routes = ref.watch(_routesForAnnouncementsProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          top: AppSpacing.sm,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.colors.outlineVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: context.colors.primaryContainer,
                    foregroundColor: context.colors.onPrimaryContainer,
                    child: const Icon(Icons.campaign_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(context.l10n.announcements, style: context.text.titleLarge),
                ],
              ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _title,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: context.l10n.announcements),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _body,
            maxLines: 3,
            decoration: InputDecoration(hintText: context.l10n.announcementComposeHint),
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<AnnouncementScope>(
            segments: <ButtonSegment<AnnouncementScope>>[
              ButtonSegment<AnnouncementScope>(
                value: AnnouncementScope.school,
                label: Text(context.l10n.announcementScopeSchool),
              ),
              ButtonSegment<AnnouncementScope>(
                value: AnnouncementScope.route,
                label: Text(context.l10n.announcementScopeRoute),
              ),
            ],
            selected: <AnnouncementScope>{_scope},
            onSelectionChanged: (Set<AnnouncementScope> s) => setState(() => _scope = s.first),
          ),
          if (_scope == AnnouncementScope.route) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            routes.when(
              data: (List<BusRoute> items) => DropdownButtonFormField<String>(
                initialValue: _routeId,
                decoration: InputDecoration(labelText: context.l10n.routeLabel),
                items: <DropdownMenuItem<String>>[
                  for (final BusRoute r in items) DropdownMenuItem<String>(value: r.id, child: Text(r.name)),
                ],
                onChanged: (String? v) => setState(() => _routeId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _submitting ? null : _publish,
            child: _submitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(context.l10n.announcementPublish),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _publish() async {
    final String? adminId = ref.read(authControllerProvider).user?.id;
    if (adminId == null || _title.text.trim().isEmpty) return;
    setState(() => _submitting = true);
    await ref.read(announcementRepositoryProvider).publish(
          Announcement(
            id: '',
            schoolId: MockIds.schoolId,
            title: _title.text.trim(),
            body: _body.text.trim(),
            scope: _scope,
            routeId: _scope == AnnouncementScope.route ? _routeId : null,
            createdBy: adminId,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
