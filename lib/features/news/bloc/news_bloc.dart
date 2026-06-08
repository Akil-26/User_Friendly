import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/news_repository.dart';
import 'news_event.dart';
import 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final NewsRepository _newsRepository;

  NewsBloc(this._newsRepository) : super(NewsInitial()) {

    on<NewsFeedRequested>((event, emit) async {
      emit(NewsLoading());
      try {
        final articles = await _newsRepository.getFeed(limit: event.limit);
        emit(NewsLoaded(articles: articles));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });

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

    on<NewsRefreshRequested>((event, emit) async {
      emit(NewsLoading());
      try {
        final articles = await _newsRepository.getFeed();
        emit(NewsLoaded(articles: articles));
      } catch (e) {
        emit(NewsError(e.toString()));
      }
    });
  }
}