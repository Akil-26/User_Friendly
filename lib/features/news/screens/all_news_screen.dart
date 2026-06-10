import 'package:flutter/material.dart';
import 'package:flutter_app/core/api/api_service.dart';
import 'package:flutter_app/features/news/repository/news_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/utils.dart';
import '../../../core/widgets/status_view.dart';
import 'widgets/article_card.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  String _selected = 'All';
  List<String> _allTopics = ['All'];

  @override
  void initState() {
    super.initState();
    _loadTopicsAndFeed();
  }

  Future<void> _loadTopicsAndFeed() async {
    // load explore feed
    context.read<NewsBloc>().add(NewsExploreRequested());

    // load dynamic topic list from backend
    try {
      final repo = NewsRepository(ApiService());
      final topics = await repo.getTopics();
      final all = topics['all'] ?? [];
      setState(() {
        _allTopics = ['All', ...all];
      });
    } catch (_) {
      // fallback to built-in
      setState(() {
        _allTopics = [
          'All', 'tech', 'sports', 'finance', 'science',
          'health', 'politics', 'world', 'business',
          'entertainment', 'gaming', 'india',
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    AppSizes.init(context);
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

        // Dynamic topic tabs
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: AppSizes.spaceMd),
            itemCount: _allTopics.length,
            itemBuilder: (context, index) {
              final topic = _allTopics[index];
              final isSelected = _selected == topic;
              final displayLabel = topic == 'All' ? '# All' : '# $topic';

              return GestureDetector(
                onTap: () {
                  setState(() => _selected = topic);
                  if (topic == 'All') {
                    context.read<NewsBloc>().add(NewsExploreRequested());
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
                    borderRadius: BorderRadius.circular(
                        AppSizes.radiusCircular),
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
                      .add(NewsExploreRequested()),
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
                      .add(NewsExploreRequested()),
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