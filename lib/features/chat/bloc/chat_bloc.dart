import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/chat_repository.dart';
import '../services/chat_local_storage.dart';
import '../models/chat_message_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _chatRepository;
  final ChatLocalStorage _localStorage;

  ChatBloc(this._chatRepository, this._localStorage) : super(ChatInitial()) {

    // ── Load history from SQLite ──────────────────────────
    on<ChatHistoryLoaded>((event, emit) async {
      emit(ChatEmbedding());
      try {
        final messages = await _localStorage.getMessages(event.articleUrl);
        emit(ChatReady(messages: messages));
      } catch (_) {
        emit(ChatReady(messages: []));
      }
    });

    // ── Embed article (called on YES tap) ─────────────────
    on<ChatEmbedRequested>((event, emit) async {
      emit(ChatEmbedding());
      try {
        await _chatRepository.embedArticle(
          articleUrl: event.articleUrl,
          articleTitle: event.articleTitle,
        );
        // load existing history after embedding
        final messages = await _localStorage.getMessages(event.articleUrl);
        emit(ChatReady(messages: messages));
      } catch (e) {
        emit(ChatError(e.toString()));
      }
    });

    // ── Ask question ──────────────────────────────────────
    on<ChatQuestionAsked>((event, emit) async {
      if (state is! ChatReady) return;
      final current = state as ChatReady;

      // Add user message immediately
      final userMessage = ChatMessageModel(
        content: event.question,
        isUser: true,
        timestamp: DateTime.now(),
      );
      await _localStorage.saveMessage(event.articleUrl, userMessage);

      emit(current.copyWith(
        messages: [...current.messages, userMessage],
        isAnswering: true,
      ));

      try {
        final answer = await _chatRepository.askQuestion(
          articleUrl: event.articleUrl,
          question: event.question,
        );

        // Add AI answer
        final aiMessage = ChatMessageModel(
          content: answer,
          isUser: false,
          timestamp: DateTime.now(),
        );
        await _localStorage.saveMessage(event.articleUrl, aiMessage);

        final updated = state as ChatReady;
        emit(updated.copyWith(
          messages: [...updated.messages, aiMessage],
          isAnswering: false,
        ));
      } catch (e) {
        final updated = state as ChatReady;
        emit(updated.copyWith(isAnswering: false));
        emit(ChatError(e.toString()));
      }
    });

    // ── Clear chat history ────────────────────────────────
    on<ChatCleared>((event, emit) async {
      await _localStorage.clearMessages(event.articleUrl);
      emit(ChatReady(messages: []));
    });
  }
}