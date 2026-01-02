import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/providers/post_provider.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/screens/main_nav_screen.dart';
import 'package:chatapp/theme.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final List<String> _tags = [];
  bool _submitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _submitting = true);

    final provider = Provider.of<PostProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!auth.isAuthenticated) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please sign in to create a post'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final username = auth.currentUser?.username ?? 'Anonymous';
    final tagString = _tags.map((t) => t.startsWith('#') ? t : '#$t').join(' ');
    final fullContent =
        content + (tagString.isNotEmpty ? '\n\n$tagString' : '');

    await provider.addPost(username, fullContent);

    if (mounted) {
      setState(() => _submitting = false);
      _contentController.clear();
      _tags.clear();
      mainNavKey.currentState?.setIndex(0); // Switch to feed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post published')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Post',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLg,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _contentController,
                      decoration: InputDecoration(
                        hintText: "What's on your mind?",
                        hintStyle: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant
                              .withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ..._tags.map((t) => Chip(
                              label: Text(t.startsWith('#') ? t : '#$t'),
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              labelStyle: TextStyle(
                                  color:
                                      theme.colorScheme.onSecondaryContainer),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () => setState(() => _tags.remove(t)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              side: BorderSide.none,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border(
                  top: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                const Icon(Icons.tag, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      hintText: 'Add a tag...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onSubmitted: (value) {
                      final v = value.trim();
                      if (v.isNotEmpty) {
                        setState(() {
                          _tags.add(v.startsWith('#') ? v : '#$v');
                          _tagsController.clear();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: theme.colorScheme.primary,
                  onPressed: () {
                    final v = _tagsController.text.trim();
                    if (v.isNotEmpty) {
                      setState(() {
                        _tags.add(v.startsWith('#') ? v : '#$v');
                        _tagsController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
