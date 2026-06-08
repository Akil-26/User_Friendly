class ChatMessageModel {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageModel({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  // For saving to SQLite locally
  Map<String, dynamic> toMap(String articleUrl) => {
    'content': content,
    'is_user': isUser ? 1 : 0,
    'timestamp': timestamp.toIso8601String(),
    'article_url': articleUrl,
  };

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      content: map['content'],
      isUser: map['is_user'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}