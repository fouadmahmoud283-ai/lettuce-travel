/// One parent-to-school conversation.
class MessageThread {
  const MessageThread({
    required this.id,
    required this.schoolId,
    required this.guardianId,
    this.unreadForGuardian = 0,
    this.unreadForSchool = 0,
    this.lastMessageAt,
  });

  final String id;
  final String schoolId;
  final String guardianId;
  final int unreadForGuardian;
  final int unreadForSchool;
  final DateTime? lastMessageAt;
}

/// One message inside a [MessageThread].
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.senderIsSchool,
    required this.text,
    this.sentAt,
  });

  final String id;
  final String threadId;
  final String senderId;

  /// True when the school (admin) sent this message, false for the guardian.
  final bool senderIsSchool;

  final String text;
  final DateTime? sentAt;
}
