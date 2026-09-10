import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/constants/mock_ids.dart';
import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/announcement.dart';
import 'package:lettuce_travel/features/messaging/domain/repositories/announcement_repository.dart';

/// In-memory stand-in for the Firestore `announcements` collection.
class FakeAnnouncementRepository implements AnnouncementRepository {
  FakeAnnouncementRepository() {
    _announcements.seed(<Announcement>[
      Announcement(
        id: 'ann_seed_01',
        schoolId: MockIds.schoolId,
        title: 'Welcome back!',
        body: 'The new term starts Sunday. Bus routes are unchanged from last term.',
        scope: AnnouncementScope.school,
        createdBy: MockIds.adminUid,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);
  }

  final MockCollection<Announcement> _announcements = MockCollection<Announcement>();
  int _seq = 0;

  @override
  Stream<List<Announcement>> watchSchoolAnnouncements(String schoolId) => _announcements
      .watch((Announcement a) => a.schoolId == schoolId)
      .map(_newestFirst);

  @override
  Stream<List<Announcement>> watchAnnouncementsFor({
    required String schoolId,
    required List<String> routeIds,
  }) =>
      _announcements
          .watch(
            (Announcement a) =>
                a.schoolId == schoolId &&
                (a.scope == AnnouncementScope.school ||
                    (a.routeId != null && routeIds.contains(a.routeId))),
          )
          .map(_newestFirst);

  List<Announcement> _newestFirst(List<Announcement> items) => List<Announcement>.of(items)
    ..sort(
      (Announcement a, Announcement b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
    );

  @override
  Future<Result<Announcement>> publish(Announcement announcement) async {
    _seq++;
    final Announcement stored = Announcement(
      id: 'ann_$_seq',
      schoolId: announcement.schoolId,
      title: announcement.title,
      body: announcement.body,
      scope: announcement.scope,
      routeId: announcement.routeId,
      createdBy: announcement.createdBy,
      createdAt: DateTime.now(),
    );
    _announcements.add(stored);
    return Result<Announcement>.ok(stored);
  }
}

final Provider<AnnouncementRepository> announcementRepositoryProvider =
    Provider<AnnouncementRepository>((Ref ref) => FakeAnnouncementRepository());
