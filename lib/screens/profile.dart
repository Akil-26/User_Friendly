import 'package:flutter/material.dart';

import '../services/tag_storage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  final TagStorageService _tagStorageService = TagStorageService();
  final TextEditingController _tagController = TextEditingController();

  List<String> _tags = <String>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final List<String> tags = await _tagStorageService.loadTags();
    if (!mounted) {
      return;
    }

    setState(() {
      _tags = tags;
      _isLoading = false;
    });
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
  }

  Future<void> _removeTag(String tag) async {
    final List<String> updatedTags = _tags
        .where((String currentTag) => currentTag != tag)
        .toList();
    await _tagStorageService.saveTags(updatedTags);
    if (!mounted) {
      return;
    }

    setState(() {
      _tags = updatedTags;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add tag',
            onPressed: _openAddTagDialog,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'My tags',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_tags.isEmpty)
                          Text(
                            'Add tags to personalize your home feed.',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        if (_tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _tags
                                .map(
                                  (String tag) => InputChip(
                                    label: Text('#$tag'),
                                    onDeleted: () => _removeTag(tag),
                                  ),
                                )
                                .toList(),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        const Text(
                          'Quick add',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _suggestedTags
                              .map(
                                (String tag) => ActionChip(
                                  label: Text(tag),
                                  onPressed: _tags.contains(tag)
                                      ? null
                                      : () => _addTag(tag),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Changes here update Home feed topics.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
