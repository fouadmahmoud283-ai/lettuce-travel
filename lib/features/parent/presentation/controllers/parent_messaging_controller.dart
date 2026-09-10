import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/features/auth/presentation/controllers/auth_controller.dart';
import 'package:lettuce_travel/features/messaging/data/repositories/fake_announcement_repository.dart';
import 'package:lettuce_travel/features/messaging/data/repositories/fake_message_repository.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/announcement.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/chat_message.dart';
import 'package:lettuce_travel/features/parent/presentation/controllers/parent_children_controller.dart';

/// School-wide announcements, plus any scoped to one of the guardian's
/// children's routes.
final StreamProvider<List<Announcement>> parentAnnouncementsProvider =
    StreamProvider<List<Announcement>>((Ref ref) {
  final String? guardianId = ref.watch(authControllerProvider).user?.id;
  if (guardianId == null) return Stream<List<Announcement>>.value(const <Announcement>[]);

  final List<String> routeIds = (ref.watch(parentChildrenProvider).asData?.value ?? const [])
      .map((ParentChildSummary s) => s.student.routeId)
      .toSet()
      .toList();

  return ref
      .watch(announcementRepositoryProvider)
      .watchAnnouncementsFor(schoolId: MockIds.schoolId, routeIds: routeIds);
});

final StreamProvider<MessageThread?> parentThreadProvider =
    StreamProvider<MessageThread?>((Ref ref) {
  final String? guardianId = ref.watch(authControllerProvider).user?.id;
  if (guardianId == null) return Stream<MessageThread?>.value(null);
  return ref
      .watch(messageRepositoryProvider)
      .watchOrCreateThread(schoolId: MockIds.schoolId, guardianId: guardianId);
});

final StreamProvider<List<ChatMessage>> parentMessagesProvider =
    StreamProvider<List<ChatMessage>>((Ref ref) {
  final MessageThread? thread = ref.watch(parentThreadProvider).asData?.value;
  if (thread == null) return Stream<List<ChatMessage>>.value(const <ChatMessage>[]);
  return ref.watch(messageRepositoryProvider).watchMessages(thread.id);
});
