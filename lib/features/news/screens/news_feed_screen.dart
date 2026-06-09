import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_state.dart';
import '../bloc/news_event.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/status_view.dart';
import 'widgets/article_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({super.key});

  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String _activeChip = 'All';

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Greeting
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final name = state is AuthAuthenticated
                ? state.user.name.split(' ').first
                : 'there';
            return Padding(
              padding: EdgeInsets.fromLTRB(
                AppSizes.spaceLg,
                AppSizes.spaceSm,
                AppSizes.spaceLg,
                4.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_greeting()}, $name 👋',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14.sp,
                      color: kGrayText,
                    ),
                  ),
                  Text(
                    'Your daily feed',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: kDarkText,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // Interest chips
        BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final interests = state is AuthAuthenticated
                ? state.user.interests
                : <String>[];
            return SizedBox(
              height: 40.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSizes.spaceMd),
                children: [
                  _chip(context, 'All'),
                  ...interests.map((i) => _chip(context, i)),
                ],
              ),
            );
          },
        ),

        SizedBox(height: AppSizes.spaceSm),

        // Articles
        Expanded(
          child: BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              if (state is NewsLoading) {
                return const StatusView(type: StatusType.loading);
              }
              if (state is NewsError) {
                return StatusView(
                  type: StatusType.error,
                  message: state.message,
                  actionLabel: 'Try again',
                  onAction: () => context
                      .read<NewsBloc>()
                      .add(NewsFeedRequested()),
                );
              }
              if (state is NewsLoaded) {
                if (state.articles.isEmpty) {
                  return const StatusView(
                    type: StatusType.empty,
                    message: 'No articles found for this topic',
                  );
                }
                return RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () async => context
                      .read<NewsBloc>()
                      .add(NewsRefreshRequested()),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.spaceMd),
                    itemCount: state.articles.length,
                    itemBuilder: (context, index) =>
                        ArticleCard(article: state.articles[index]),
                  ),
                );
              }
              return const StatusView(
                type: StatusType.empty,
                message: 'Pull to refresh',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(BuildContext context, String label) {
    final isSelected = _activeChip == label;
    return GestureDetector(
      onTap: () {
        setState(() => _activeChip = label);
        if (label == 'All') {
          context.read<NewsBloc>().add(NewsFeedRequested());
        } else {
          context
              .read<NewsBloc>()
              .add(NewsFeedByInterestRequested(interest: label));
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusCircular),
          border: Border.all(
            color: isSelected
                ? kPrimaryColor
                : Colors.grey.withAlpha(51), // 20% opacity
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.playfairDisplay(
            fontSize: 13.sp,
            color: isSelected ? Colors.white : kGrayText,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}