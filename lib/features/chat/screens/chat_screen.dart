import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import '../../news/models/article_model.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../models/chat_message_model.dart';
import '../repository/chat_repository.dart';
import '../services/chat_local_storage.dart';
import '../../../core/api/api_service.dart';

class ChatScreen extends StatefulWidget {
  final ArticleModel article;
  const ChatScreen({super.key, required this.article});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController  = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    context.read<ChatBloc>().add(ChatQuestionAsked(
      articleUrl: widget.article.link,
      question: text,
    ));
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    return BlocProvider(
      create: (_) => ChatBloc(
        ChatRepository(ApiService()),
        ChatLocalStorage(),
      )..add(ChatEmbedRequested(
          articleUrl: widget.article.link,
          articleTitle: widget.article.title,
        )),
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 22.sp),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chat with AI',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              Text(
                widget.article.source,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 12.sp,
                  color: kGrayText,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is! ChatReady) return const SizedBox();
                return IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red, size: 22.sp),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: kBgColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      title: Text(
                        'Clear chat',
                        style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                        'Delete all messages for this article?',
                        style: GoogleFonts.playfairDisplay(color: kGrayText),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('Cancel',
                              style: GoogleFonts.playfairDisplay(color: kGrayText)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            context.read<ChatBloc>().add(
                                  ChatCleared(widget.article.link),
                                );
                          },
                          child: Text('Clear',
                              style: GoogleFonts.playfairDisplay(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is ChatReady) _scrollToBottom();
            if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {

            if (state is ChatEmbedding) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: kPrimaryColor),
                    SizedBox(height: AppSizes.spaceMd),
                    Text(
                      'Reading article...',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: kDarkText,
                      ),
                    ),
                    SizedBox(height: AppSizes.spaceSm),
                    Text(
                      'Preparing AI context',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 13.sp,
                        color: kGrayText,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ChatReady) {
              return Column(
                children: [
                  // Article banner
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizes.spaceMd),
                    color: kPrimaryColor.withAlpha(20), // 8% opacity
                    child: Row(
                      children: [
                        Icon(Icons.article_outlined,
                            size: 16.sp, color: kPrimaryColor),
                        SizedBox(width: AppSizes.spaceSm),
                        Expanded(
                          child: Text(
                            widget.article.title,
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: kDarkText,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Messages
                  Expanded(
                    child: state.messages.isEmpty
                        ? _EmptyChat(articleUrl: widget.article.link)
                        : ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.all(AppSizes.spaceMd),
                            itemCount: state.messages.length +
                                (state.isAnswering ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == state.messages.length &&
                                  state.isAnswering) {
                                return const _TypingIndicator();
                              }
                              return _MessageBubble(
                                message: state.messages[index],
                              );
                            },
                          ),
                  ),

                  // Input
                  _ChatInputBar(
                    controller: _messageController,
                    isAnswering: state.isAnswering,
                    onSend: () => _sendMessage(context),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// ── Empty chat ────────────────────────────────────────────

class _EmptyChat extends StatelessWidget {
  final String articleUrl;
  const _EmptyChat({required this.articleUrl});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'What is this article about?',
      'What are the key points?',
      'Summarize this for me',
    ];

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.spaceLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: kPrimaryColor.withAlpha(26), // 10% opacity
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 40.sp,
                color: kPrimaryColor,
              ),
            ),
            SizedBox(height: AppSizes.spaceMd),
            Text(
              'Ask anything about this article',
              style: GoogleFonts.playfairDisplay(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
            SizedBox(height: AppSizes.spaceSm),
            Text(
              'The AI will answer using only\nthe article content',
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 13.sp,
                color: kGrayText,
              ),
            ),
            SizedBox(height: AppSizes.spaceLg),
            ...suggestions.map((q) => Padding(
                  padding: EdgeInsets.only(bottom: AppSizes.spaceSm),
                  child: GestureDetector(
                    onTap: () => context.read<ChatBloc>().add(
                          ChatQuestionAsked(
                            articleUrl: articleUrl,
                            question: q,
                          ),
                        ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceMd,
                        vertical: AppSizes.spaceMd,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                        border: Border.all(
                          color: kPrimaryColor.withAlpha(77), // 30% opacity
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 16.sp, color: kPrimaryColor),
                          SizedBox(width: AppSizes.spaceSm),
                          Expanded(
                            child: Text(
                              q,
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 13.sp,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios,
                              size: 12.sp, color: kPrimaryColor),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.smart_toy_outlined,
                  size: 16.sp, color: Colors.white),
            ),
            SizedBox(width: AppSizes.spaceSm),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                color: isUser ? kPrimaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(isUser ? 16.r : 4.r),
                  bottomRight: Radius.circular(isUser ? 4.r : 16.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(10), // 4% opacity
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: GoogleFonts.playfairDisplay(
                  color: isUser ? Colors.white : kDarkText,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: AppSizes.spaceSm),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.person, size: 16.sp, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Typing indicator ──────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: kPrimaryColor,
            child: Icon(Icons.smart_toy_outlined,
                size: 16.sp, color: Colors.white),
          ),
          SizedBox(width: AppSizes.spaceSm),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.r),
                topRight: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
                bottomLeft: Radius.circular(4.r),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(),
                SizedBox(width: 4.w),
                _dot(),
                SizedBox(width: 4.w),
                _dot(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (_, value, __) => Opacity(
        opacity: 0.3 + (value * 0.7),
        child: Container(
          width: 8.w,
          height: 8.w,
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ── Chat input bar ────────────────────────────────────────

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isAnswering;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.isAnswering,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSizes.spaceMd,
        AppSizes.spaceSm,
        AppSizes.spaceMd,
        AppSizes.spaceMd + AppSizes.bottomBarHeight,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13), // 5% opacity
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isAnswering,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              style: GoogleFonts.playfairDisplay(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: isAnswering
                    ? 'AI is thinking...'
                    : 'Ask about this article...',
                hintStyle: GoogleFonts.playfairDisplay(
                  color: kGrayText,
                  fontSize: 14.sp,
                ),
                filled: true,
                fillColor: kBgColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSizes.spaceSm),
          GestureDetector(
            onTap: isAnswering ? null : onSend,
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isAnswering ? kGrayText : kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isAnswering ? Icons.hourglass_top : Icons.send_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}