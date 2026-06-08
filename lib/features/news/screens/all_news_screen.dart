import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';
import '../bloc/news_state.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/article_card.dart';

class AllNewsScreen extends StatefulWidget {
  const AllNewsScreen({super.key});

  @override
  State<AllNewsScreen> createState() => _AllNewsScreenState();
}

class _AllNewsScreenState extends State<AllNewsScreen> {
  final List<String> _topics = [
    'All', 'tech', 'sports', 'finance', 'science',
    'health', 'politics', 'world', 'business',
    'entertainment', 'gaming', 'india',
  ];
  String _selected = 'All';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page title
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: Text(
            'Explore',
            style: GoogleFonts.playfairDisplay(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kDarkText,
            ),
          ),
        ),

        // Category tabs
        SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _topics.length,
            itemBuilder: (context, index) {
              final topic = _topics[index];
              final isSelected = _selected == topic;
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
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? kPrimaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? kPrimaryColor
                          : Colors.grey.withAlpha(51), // 20% opacity
                    ),
                  ),
                  child: Text(
                    topic,
                    style: TextStyle(
                      color: isSelected ? Colors.white : kGrayText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Articles
        Expanded(
          child: BlocBuilder<NewsBloc, NewsState>(
            builder: (context, state) {
              if (state is NewsLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
              }
              if (state is NewsError) {
                return Center(child: Text(state.message));
              }
              if (state is NewsLoaded) {
                return RefreshIndicator(
                  color: kPrimaryColor,
                  onRefresh: () async =>
                      context.read<NewsBloc>().add(NewsRefreshRequested()),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.articles.length,
                    itemBuilder: (context, index) =>
                        ArticleCard(article: state.articles[index]),
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