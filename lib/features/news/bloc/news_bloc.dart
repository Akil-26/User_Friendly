import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc(this._newsRepository) : super(NewsInitial()) {

    // Home page — user interests only
    on<NewsFeedRequested>((event, emit) async {
      emit(NewsLoading());
      try {
        final articles = await _newsRepository.getFeed(limit: event.limit);
        emit(NewsLoaded(articles: articles));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });

    // Single topic chip tap — both pages
    on<NewsFeedByInterestRequested>((event, emit) async {
      emit(NewsLoading());
      try {
        final articles = await _newsRepository.getFeedByInterest(
          event.interest,
          limit: event.limit,
        );
        emit(NewsLoaded(
          articles: articles,
          activeInterest: event.interest,
        ));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });

    // Home page refresh
    on<NewsRefreshRequested>((event, emit) async {
      emit(NewsLoading());
      try {
        final articles = await _newsRepository.getFeed();
        emit(NewsLoaded(articles: articles));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });

    // Explore/Feed page — all built-in + user custom topics
    on<NewsExploreRequested>((event, emit) async {
      emit(NewsLoading());
      try {
        final articles = await _newsRepository.getExploreFeed(
          limit: event.limit,
        );
        emit(NewsLoaded(articles: articles));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });
  }
}