import 'package:equatable/equatable.dart';

abstract class NewsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class NewsFeedRequested extends NewsEvent {
  final int limit;
  NewsFeedRequested({this.limit = 10});

  @override
  List<Object?> get props => [limit];
}

class NewsFeedByInterestRequested extends NewsEvent {
  final String interest;
  final int limit;

  NewsFeedByInterestRequested({
    required this.interest,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [interest, limit];
}

class NewsRefreshRequested extends NewsEvent {}