import 'package:equatable/equatable.dart';
import '../models/chat_message_model.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatEmbedding extends ChatState {}   // scraping + embedding

class ChatReady extends ChatState {
  final List<ChatMessageModel> messages;
  final bool isAnswering;

  ChatReady({
    required this.messages,
    this.isAnswering = false,
  });

  ChatReady copyWith({
    List<ChatMessageModel>? messages,
    bool? isAnswering,
  }) {
    return ChatReady(
      messages: messages ?? this.messages,
      isAnswering: isAnswering ?? this.isAnswering,
    );
  }

  @override
  List<Object?> get props => [messages, isAnswering];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}