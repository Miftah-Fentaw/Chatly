import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/providers/post_provider.dart';
import 'package:chatapp/providers/auth_provider.dart';
import 'package:chatapp/screens/main_nav_screen.dart';

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
    setState(() => _submitting = true);

    final provider = Provider.of<PostProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in to create a post')));
      return;
    }
    final username = auth.currentUser?.username ?? 'Anonymous';
    final tagString = _tags.map((t) => t.startsWith('#') ? t : '#$t').join(' ');
    final fullContent = _contentController.text.trim() + (tagString.isNotEmpty ? '\n\n$tagString' : '');
    await provider.addPost(username, fullContent);

    mainNavKey.currentState?.setIndex(0);

    setState(() => _submitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created')));
      _contentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'What’s on your mind?',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter some content' : null,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._tags.map((t) => Chip(
                        label: Text(t.startsWith('#') ? t : '#$t'),
                        onDeleted: () {
                          setState(() => _tags.remove(t));
                        },
                      )),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        hintText: 'Add tag',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        final v = value.trim();
                        if (v.isEmpty) return;
                        setState(() {
                          _tags.add(v.startsWith('#') ? v : '#$v');
                          _tagsController.clear();
                        });
                      },
                      onChanged: (value) {
                        if (value.contains(' ')) {
                          final parts = value.split(RegExp(r'\s+'));
                          for (var i = 0; i < parts.length - 1; i++) {
                            final p = parts[i].trim();
                            if (p.isEmpty) continue;
                            setState(() => _tags.add(p.startsWith('#') ? p : '#$p'));
                          }
                          final last = parts.last;
                          _tagsController.text = last;
                          _tagsController.selection = TextSelection.fromPosition(TextPosition(offset: _tagsController.text.length));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting ? const CircularProgressIndicator() : const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}