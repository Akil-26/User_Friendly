import 'package:shared_preferences/shared_preferences.dart';

const List<String> kDefaultNewsTags = <String>[
  'technology',
  'business',
  'health',
  'india',
];

class TagStorageService {
  static const String _tagsKey = 'news_user_tags';

  Future<List<String>> loadTags() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final List<String> savedTags =
        preferences.getStringList(_tagsKey) ?? <String>[];
    final List<String> cleanedTags = _cleanTags(savedTags);

    if (cleanedTags.isNotEmpty) {
      if (!_sameList(savedTags, cleanedTags)) {
        await preferences.setStringList(_tagsKey, cleanedTags);
      }
      return cleanedTags;
    }

    await preferences.setStringList(_tagsKey, kDefaultNewsTags);
    return List<String>.from(kDefaultNewsTags);
  }

  Future<void> saveTags(List<String> tags) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_tagsKey, _cleanTags(tags));
  }

  List<String> _cleanTags(List<String> tags) {
    final Set<String> seen = <String>{};
    final List<String> output = <String>[];

    for (final String tag in tags) {
      final String normalized = tag.trim().toLowerCase();
      if (normalized.isEmpty || seen.contains(normalized)) {
        continue;
      }
      seen.add(normalized);
      output.add(normalized);
    }

    return output;
  }

  bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) {
      return false;
    }

    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }

    return true;
  }
}
