import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/app/theme/app_spacing.dart';
import 'package:lettuce_travel/core/extensions/context_x.dart';
import 'package:lettuce_travel/core/extensions/date_x.dart';
import 'package:lettuce_travel/core/widgets/async_value_view.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/announcement.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/chat_message.dart';
import 'package:lettuce_travel/features/messaging/data/repositories/fake_message_repository.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_messaging_controller.dart';

class ParentMessagesScreen extends ConsumerWidget {
  const ParentMessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.messagesTitle),
            bottom: TabBar(
              tabs: <Widget>[
                Tab(text: context.l10n.announcements),
                Tab(text: context.l10n.messagesTitle),
              ],
            ),
          ),
          body: const TabBarView(
            children: <Widget>[_AnnouncementsTab(), _ChatTab()],
          ),
        ),
      );
}

class _AnnouncementsTab extends ConsumerWidget {
  const _AnnouncementsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Announcement>> announcements = ref.watch(parentAnnouncementsProvider);
    return SafeArea(
      child: AsyncValueView<List<Announcement>>(
        value: announcements,
        data: (List<Announcement> items) => items.isEmpty
            ? Center(child: Text(context.l10n.announcementsEmpty))
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (BuildContext context, int index) {
                  final Announcement a = items[index];
                  return Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(a.title, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSpacing.xs),
                        Text(a.body, style: context.text.bodyMedium),
                        if (a.createdAt != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            a.createdAt!.toClockTime(context.l10n.localeName),
                            style: context.text.bodySmall
                                ?.copyWith(color: context.colors.onSurfaceVariant),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _ChatTab extends ConsumerStatefulWidget {
  const _ChatTab();

  @override
  ConsumerState<_ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<_ChatTab> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ChatMessage>> messages = ref.watch(parentMessagesProvider);
    return SafeArea(
      child: Column(
        children: <Widget>[
          Expanded(
            child: AsyncValueView<List<ChatMessage>>(
              value: messages,
              data: (List<ChatMessage> items) => items.isEmpty
                  ? Center(child: Text(context.l10n.messagesEmpty))
                  : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final ChatMessage message = items[items.length - 1 - index];
                        final bool mine = !message.senderIsSchool;
                        return Align(
                          alignment: mine ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                          child: Container(
                            margin: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            constraints: BoxConstraints(maxWidth: context.screenSize.width * 0.75),
                            decoration: BoxDecoration(
                              color: mine ? context.colors.primaryContainer : context.colors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            ),
                            child: Text(message.text),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: context.l10n.messageHint),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filled(
                  icon: const Icon(Icons.send_rounded),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    final String? guardianId = ref.read(authControllerProvider).user?.id;
    final String? threadId = ref.read(parentThreadProvider).asData?.value?.id;
    if (guardianId == null || threadId == null) return;
    _controller.clear();
    await ref.read(messageRepositoryProvider).sendMessage(
          threadId: threadId,
          senderId: guardianId,
          senderIsSchool: false,
          text: text,
        );
  }
}
