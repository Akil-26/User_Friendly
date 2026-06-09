import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/article_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../chat/screens/chat_screen.dart';

// ── HOME CARD — full detail with Chat with AI ─────────────
class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  const ArticleCard({super.key, required this.article});

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Confirmation to ask with AI',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        content: Text(
          'It does not generate predicted or AI-created results. Instead, it uses news-context embeddings to provide relevant information, ensuring that no unwanted or irrelevant news appears in the chat page.',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(color: kGrayText, fontSize: 13.sp),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kGrayText),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.playfairDisplay(color: kGrayText, fontSize: 13.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatScreen(article: article)),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
              elevation: 0,
            ),
            child: Text('Yes', style: GoogleFonts.playfairDisplay(fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = kPrimaryColor;
    return GestureDetector(
      onTap: () => _openArticle(article.link),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          // no shadow — clean flat look
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Source + topic + date
              Row(
                children: [
                  Text(
                    article.source.toUpperCase(),
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: kGrayText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 7.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      article.interest.toUpperCase(),
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    article.publishedDisplay,
                    style: GoogleFonts.playfairDisplay(fontSize: 10.sp, color: kGrayText),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Title — bigger
              Text(
                article.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 18.sp, // was 15.sp → now 18.sp
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // Summary — medium size
              if (article.summary.isNotEmpty) ...[
                SizedBox(height: 7.h),
                Text(
                  article.summary,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 13.sp, // medium — same as before but more lines
                    color: kGrayText,
                  ),
                  maxLines: 3, // was 2 → now 3 lines
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 10.h),

              // Chat with AI — bottom right
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showChatDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 15.h,
                      ),
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.smart_toy_outlined,
                            size: 13.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 5.w),
                          Text(
                            'Chat with AI',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FEED CARD — Samsung One UI notification style ─────────
class FeedNotificationCard extends StatelessWidget {
  final ArticleModel article;
  const FeedNotificationCard({super.key, required this.article});

  Future<void> _openArticle(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = kPrimaryColor;
    return GestureDetector(
      onTap: () => _openArticle(article.link),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
        decoration: BoxDecoration(
          // exact One UI pill — dark fill, fully rounded
          color: kCardColor.withAlpha(230), // slightly transparent for that layered look
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: Row(
          children: [

            // ── Left: topic icon pill ───────────────────
            Container(
              width: 55.w,
              height: 55.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Center(
                child: Text(
                  article.interest[0].toUpperCase(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: kBgColor,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // ── Middle: source + title ──────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Source name + time — same row like One UI
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.source,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: kGrayText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        article.publishedDisplay,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 10.sp,
                          color: kGrayText,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 3.h),

                  // Title — white bold like One UI notification
                  Text(
                    article.title,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: kDarkText,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}