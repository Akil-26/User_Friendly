import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../models/news_article.dart';
import 'news_service.dart';
import 'tag_storage_service.dart';

const String _kBackgroundTaskUniqueName = 'user_friendly_periodic_news';
const String _kBackgroundTaskName = 'user_friendly_refresh_news';
const String _kSeenNewsIdsKey = 'seen_news_article_ids';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((String task, Map<String, dynamic>? inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    final NotificationService notificationService = NotificationService();
    await notificationService.initialize();
    final List<String> tags = await TagStorageService().loadTags();
    await notificationService.notifyForLatestNews(tags);
    return Future<bool>.value(true);
  });
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService _singleton = NotificationService._internal();

  factory NotificationService() => _singleton;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  bool _backgroundTaskRegistered = false;

  static bool get isSupportedPlatform {
    if (kIsWeb) {
      return false;
    }

    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> initialize() async {
    if (!isSupportedPlatform) {
      return;
    }

    if (_initialized) {
      return;
    }

    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(settings);
    await _requestNotificationPermissions();
    _initialized = true;
  }

  Future<void> configureBackgroundRefresh() async {
    if (!isSupportedPlatform) {
      return;
    }

    if (_backgroundTaskRegistered) {
      return;
    }

    await Workmanager().initialize(
      callbackDispatcher,
      // ignore: deprecated_member_use
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      _kBackgroundTaskUniqueName,
      _kBackgroundTaskName,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(minutes: 2),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    _backgroundTaskRegistered = true;
  }

  Future<void> notifyForLatestNews(List<String> tags) async {
    final List<NewsArticle> latestArticles = await NewsService().fetchNewsByTags(
      tags,
      limitPerTag: 8,
    );

    if (latestArticles.isEmpty) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> existingIds =
        preferences.getStringList(_kSeenNewsIdsKey) ?? <String>[];

    NewsArticle? firstNewArticle;
    for (final NewsArticle article in latestArticles) {
      if (!existingIds.contains(article.id)) {
        firstNewArticle = article;
        break;
      }
    }

    if (firstNewArticle != null) {
      await showNewsUpdate(firstNewArticle);
    }

    await _saveSeenArticleIds(
      preferences: preferences,
      latestIds: latestArticles.map((NewsArticle article) => article.id).toList(),
      existingIds: existingIds,
    );
  }

  Future<void> seedSeenArticles(List<NewsArticle> articles) async {
    if (articles.isEmpty) {
      return;
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> existingIds =
        preferences.getStringList(_kSeenNewsIdsKey) ?? <String>[];

    if (existingIds.isNotEmpty) {
      return;
    }

    await _saveSeenArticleIds(
      preferences: preferences,
      latestIds: articles.map((NewsArticle article) => article.id).toList(),
      existingIds: existingIds,
    );
  }

  Future<void> showNewsUpdate(NewsArticle article) async {
    if (!isSupportedPlatform) {
      return;
    }

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'news_updates',
        'News Updates',
        channelDescription: 'Alerts for fresh stories that match your tags',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final String body = '${article.source}  |  #${article.matchedTag}';

    await _localNotificationsPlugin.show(
      article.id.hashCode,
      article.title,
      body,
      notificationDetails,
      payload: article.url,
    );
  }

  Future<void> _requestNotificationPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final IOSFlutterLocalNotificationsPlugin? iosPlugin =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final MacOSFlutterLocalNotificationsPlugin? macPlugin =
        _localNotificationsPlugin.resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>();
    await macPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _saveSeenArticleIds({
    required SharedPreferences preferences,
    required List<String> latestIds,
    required List<String> existingIds,
  }) async {
    final Set<String> unique = <String>{};
    final List<String> merged = <String>[];

    for (final String id in latestIds) {
      if (unique.add(id)) {
        merged.add(id);
      }
      if (merged.length >= 120) {
        break;
      }
    }

    if (merged.length < 120) {
      for (final String id in existingIds) {
        if (unique.add(id)) {
          merged.add(id);
        }
        if (merged.length >= 120) {
          break;
        }
      }
    }

    await preferences.setStringList(_kSeenNewsIdsKey, merged);
  }
}
