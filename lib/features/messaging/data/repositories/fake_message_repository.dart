import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lettuce_travel/core/utils/mock_collection.dart';
import 'package:lettuce_travel/core/utils/result.dart';
import 'package:lettuce_travel/features/messaging/domain/entities/chat_message.dart';
import 'package:lettuce_travel/features/messaging/domain/repositories/message_repository.dart';

/// In-memory stand-in for `threads/{threadId}/messages`.
class FakeMessageRepository implements MessageRepository {
  final MockCollection<MessageThread> _threads = MockCollection<MessageThread>();
  final MockCollection<ChatMessage> _messages = MockCollection<ChatMessage>();
  int _messageSeq = 0;

  @override
  Stream<MessageThread> watchOrCreateThread({
    required String schoolId,
    required String guardianId,
  }) {
    final bool exists =
        _threads.items.any((MessageThread t) => t.guardianId == guardianId);
    if (!exists) {
      _threads.add(
        MessageThread(id: 'thr_$guardianId', schoolId: schoolId, guardianId: guardianId),
      );
    }
    return _threads
        .watchOne((MessageThread t) => t.guardianId == guardianId)
        .where((MessageThread? t) => t != null)
        .cast<MessageThread>();
  }

  @override
  Stream<List<ChatMessage>> watchMessages(String threadId) => _messages
      .watch((ChatMessage m) => m.threadId == threadId)
      .map(
        (List<ChatMessage> items) => items.sorted(
          (ChatMessage a, ChatMessage b) =>
              (a.sentAt ?? DateTime(0)).compareTo(b.sentAt ?? DateTime(0)),
        ),
      );

  @override
  Future<Result<ChatMessage>> sendMessage({
    required String threadId,
    required String senderId,
    required bool senderIsSchool,
    required String text,
  }) async {
    _messageSeq++;
    final ChatMessage message = ChatMessage(
      id: 'msg_$_messageSeq',
      threadId: threadId,
      senderId: senderId,
      senderIsSchool: senderIsSchool,
      text: text,
      sentAt: DateTime.now(),
    );
    _messages.add(message);
    return Result<ChatMessage>.ok(message);
  }
}

final Provider<MessageRepository> messageRepositoryProvider =
    Provider<MessageRepository>((Ref ref) => FakeMessageRepository());
