import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/status_view.dart';
import 'widgets/article_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_state.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  String _selected = 'All';

  @override
  void initState() {
    super.initState();
    // load feed on init
    context.read<NewsBloc>().add(NewsFeedRequested());
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);

    // get user interests dynamically from AuthBloc
    final authState = context.read<AuthBloc>().state;
    final userInterests = authState is AuthAuthenticated
        ? authState.user.interests
        : <String>[];

    // All + user's interests only
    final topics = ['All', ...userInterests];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSizes.spaceLg, AppSizes.spaceSm,
            AppSizes.spaceLg, 10.h,
          ),
          child: Text(
            'Explore',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
        ),

        // User interest tabs only — hashtag style
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spaceMd),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final isSelected = _selected == topic;
              final displayLabel = topic == 'All' ? '# All' : '# $topic';

              return GestureDetector(
                onTap: () {
                  setState(() => _selected = topic);
                  if (topic == 'All') {
                    context.read<NewsBloc>().add(NewsFeedRequested());
                  } else {
                    context.read<NewsBloc>().add(
                      NewsFeedByInterestRequested(interest: topic),
                    );
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : Colors.white,
                    borderRadius:
                        BorderRadius.circular(AppSizes.radiusCircular),
                    border: Border.all(
                      color: isSelected
                          ? kPrimaryColor
                          : kGrayText.withAlpha(51),
                    ),
                  ),
                  child: Text(
                    displayLabel,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: isSelected ? Colors.white : kGrayText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 10.h),

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
                  onAction: () =>
                      context.read<NewsBloc>().add(NewsFeedRequested()),
                );
              }
              if (state is NewsLoaded) {
                if (state.articles.isEmpty) {
                  return const StatusView(
                    type: StatusType.empty,
                    message: 'No articles found',
                  );
                }
                return RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () async => context
                      .read<NewsBloc>()
                      .add(NewsRefreshRequested()),
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    itemCount: state.articles.length,
                    itemBuilder: (context, index) =>
                        FeedNotificationCard(
                          article: state.articles[index],
                        ),
                  ),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}