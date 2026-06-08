import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatEmbedRequested extends ChatEvent {
  final String articleUrl;
  final String articleTitle;

  ChatEmbedRequested({
    required this.articleUrl,
    required this.articleTitle,
  });

  @override
  List<Object?> get props => [articleUrl, articleTitle];
}

class ChatQuestionAsked extends ChatEvent {
  final String articleUrl;
  final String question;

  ChatQuestionAsked({
    required this.articleUrl,
    required this.question,
  });

  @override
  List<Object?> get props => [articleUrl, question];
}

class ChatHistoryLoaded extends ChatEvent {
  final String articleUrl;
  ChatHistoryLoaded(this.articleUrl);

  @override
  List<Object?> get props => [articleUrl];
}

class ChatCleared extends ChatEvent {
  final String articleUrl;
  ChatCleared(this.articleUrl);

  @override
  List<Object?> get props => [articleUrl];
}