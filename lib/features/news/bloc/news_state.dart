import 'package:equatable/equatable.dart';
import '../models/article_model.dart';

abstract class NewsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewsInitial extends NewsState {}

class NewsLoading extends NewsState {}

class NewsLoaded extends NewsState {
  final List<ArticleModel> articles;
  final String? activeInterest;

  NewsLoaded({
    required this.articles,
    this.activeInterest,
  });

  @override
  List<Object?> get props => [articles, activeInterest];
}

class NewsError extends NewsState {
  final String message;
  NewsError(this.message);

  @override
  List<Object?> get props => [message];
}