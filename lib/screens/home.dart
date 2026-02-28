import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/news_article.dart';
import '../services/news_service.dart';
import '../services/notification_service.dart';
import '../services/tag_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _suggestedTags = <String>[
    'ai',
    'startup',
    'sports',
    'science',
    'finance',
    'climate',
    'cybersecurity',
    'world',
  ];

  final NewsService _newsService = NewsService();
  final TagStorageService _tagStorageService = TagStorageService();
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _tagController = TextEditingController();

  List<String> _tags = <String>[];
  List<NewsArticle> _articles = <NewsArticle>[];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final List<String> savedTags = await _tagStorageService.loadTags();
    if (!mounted) {
      return;
    }

    setState(() {
      _tags = savedTags;
    });

    await _refreshNews(seedSeenArticles: true);
  }

  Future<void> _refreshNews({bool seedSeenArticles = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<NewsArticle> news = await _newsService.fetchNewsByTags(_tags);
      if (!mounted) {
        return;
      }

      setState(() {
        _articles = news;
        _isLoading = false;
      });

      if (seedSeenArticles) {
        await _notificationService.seedSeenArticles(news);
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Unable to load live news right now. Check your internet and try again.';
      });
    }
  }

  Future<void> _addTag(String rawTag) async {
    final String tag = rawTag.trim().toLowerCase();
    if (tag.isEmpty) {
      return;
    }

    if (_tags.contains(tag)) {
      _showMessage('Tag "$tag" is already added.');
      return;
    }

    final List<String> updatedTags = <String>[..._tags, tag];
    await _tagStorageService.saveTags(updatedTags);
    if (!mounted) {
      return;
    }

    setState(() {
      _tags = updatedTags;
    });

    await _refreshNews();
  }

  Future<void> _removeTag(String tag) async {
    final List<String> updatedTags =
        _tags.where((String currentTag) => currentTag != tag).toList();
    await _tagStorageService.saveTags(updatedTags);
    if (!mounted) {
      return;
    }

    setState(() {
      _tags = updatedTags;
    });

    await _refreshNews();
  }

  Future<void> _openArticle(NewsArticle article) async {
    final Uri? uri = Uri.tryParse(article.url);
    if (uri == null) {
      _showMessage('Cannot open this news link.');
      return;
    }

    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && mounted) {
      _showMessage('Could not open this article.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _openAddTagDialog() {
    _tagController.clear();
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add News Tag'),
          content: TextField(
            controller: _tagController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Example: electric vehicles',
            ),
            onSubmitted: (_) => _submitAddTag(dialogContext),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => _submitAddTag(dialogContext),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitAddTag(BuildContext dialogContext) async {
    final String value = _tagController.text;
    Navigator.of(dialogContext).pop();
    await _addTag(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Friendly News'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refreshNews,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Add tag',
            onPressed: _openAddTagDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _TagPanel(
            tags: _tags,
            suggestedTags: _suggestedTags,
            onDeleteTag: _removeTag,
            onTapSuggestedTag: _addTag,
          ),
          if (_isLoading && _articles.isNotEmpty)
            const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: _buildFeedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedContent() {
    if (_isLoading && _articles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _refreshNews,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: _refreshNews,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const <Widget>[
            SizedBox(height: 120),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'No stories found for your tags yet. Add another tag or refresh in a few minutes.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshNews,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: _articles.length,
        itemBuilder: (BuildContext context, int index) {
          final NewsArticle article = _articles[index];
          return _ArticleCard(
            article: article,
            onTap: () => _openArticle(article),
          );
        },
      ),
    );
  }
}

class _TagPanel extends StatelessWidget {
  const _TagPanel({
    required this.tags,
    required this.suggestedTags,
    required this.onDeleteTag,
    required this.onTapSuggestedTag,
  });

  final List<String> tags;
  final List<String> suggestedTags;
  final ValueChanged<String> onDeleteTag;
  final ValueChanged<String> onTapSuggestedTag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F7),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Your tags',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (tags.isEmpty)
            Text(
              'Add tags to build your personal daily news feed.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          if (tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (String tag) => InputChip(
                      label: Text('#$tag'),
                      onDeleted: () => onDeleteTag(tag),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 12),
          Text(
            'Quick add',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestedTags
                .map(
                  (String tag) => ActionChip(
                    label: Text(tag),
                    onPressed: () => onTapSuggestedTag(tag),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 6),
          Text(
            'Trusted publishers are prioritized in your feed.',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.onTap,
  });

  final NewsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      article.source,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.open_in_new, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                article.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade800),
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Text(
                    '#${article.matchedTag}',
                    style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _relativeTime(article.publishedAt),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
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

  String _relativeTime(DateTime publishedAt) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(publishedAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} day ago';
    }

    final String day = publishedAt.day.toString().padLeft(2, '0');
    final String month = publishedAt.month.toString().padLeft(2, '0');
    final String year = publishedAt.year.toString();
    return '$day/$month/$year';
  }
}
