import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/chat_message.dart';

/// One-to-one conversations between a parent and the school.
abstract interface class MessageRepository {
  /// The guardian's thread with the school, creating it on first use.
  Stream<MessageThread> watchOrCreateThread({
    required String schoolId,
    required String guardianId,
  });

  Stream<List<ChatMessage>> watchMessages(String threadId);

  Future<Result<ChatMessage>> sendMessage({
    required String threadId,
    required String senderId,
    required bool senderIsSchool,
    required String text,
  });
}
