import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/article_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/utils.dart';
import '../../../chat/screens/chat_screen.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  const ArticleCard({super.key, required this.article});

  Color _interestColor(String interest) {
    const colors = {
      'tech': Color(0xFF3B82F6),
      'sports': Color(0xFF10B981),
      'finance': Color(0xFFF59E0B),
      'science': Color(0xFF8B5CF6),
      'health': Color(0xFFEF4444),
      'politics': Color(0xFF6366F1),
      'world': Color(0xFF0EA5E9),
      'business': Color(0xFF92400E),
      'entertainment': Color(0xFFEC4899),
      'gaming': Color(0xFF7C3AED),
      'india': Color(0xFFFF7518),
    };
    return colors[interest.toLowerCase()] ?? kPrimaryColor;
  }

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
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
          ),
        ),
        content: Text(
          'It will not give predicted or known results from AI. It gives the news context based embeddings so it will not give any unwanted news in our chat page.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: kGrayText,
            fontSize: 13.sp,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.red, fontSize: 13.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(article: article),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              elevation: 0,
            ),
            child: Text(
              'Yes',
              style: GoogleFonts.inter(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _interestColor(article.interest);

    return GestureDetector(
      onTap: () => _openArticle(article.link),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Top: source + category tag + date (ONCE only) ──
              Row(
                children: [
                  Text(
                    article.source.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: kGrayText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: color.withAlpha(26), // 10% opacity
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      article.interest.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // ← date shown ONCE here at top right
                  Text(
                    article.publishedDisplay,
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: kGrayText,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // ── Title ──────────────────────────────────────────
              Text(
                article.title,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Summary ────────────────────────────────────────
              if (article.summary.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Text(
                  article.summary,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: kGrayText,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              SizedBox(height: 10.h),

              // ── Bottom: Chat with AI at RIGHT, no date repeat ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => _showChatDialog(context),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
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
                            style: GoogleFonts.inter(
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