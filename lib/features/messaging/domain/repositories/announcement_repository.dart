import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/announcement.dart';

/// School-wide or route-scoped announcements, written by admin, read by
/// parents (docs/data-model.md).
abstract interface class AnnouncementRepository {
  Stream<List<Announcement>> watchSchoolAnnouncements(String schoolId);

  /// Announcements relevant to a guardian: school-wide, plus any scoped to one
  /// of [routeIds] (their children's routes).
  Stream<List<Announcement>> watchAnnouncementsFor({
    required String schoolId,
    required List<String> routeIds,
  });

  Future<Result<Announcement>> publish(Announcement announcement);
}
