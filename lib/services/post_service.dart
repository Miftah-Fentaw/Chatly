import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/post_model.dart';

class PostService {
  final SupabaseClient _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  Future<List<Post>> fetchPosts() async {
    final response = await _client.from('posts').select().order('created_at', ascending: false);
    return response.map((json) => Post.fromJson(json)).toList();
  }

  Future<void> createPost(String content, String username) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final post = Post(
      id: '',
      createdAt: DateTime.now(),
      userId: user.id,
      username: username,
      content: content,
      likes: 0,
      dislikes: 0,
      angry: 0,
    );

    await _client.from('posts').insert(post.toJson());
  }

  Future<void> updateReaction(String postId, String reactionType, int increment) async {
    final current = await _client.from('posts').select(reactionType).eq('id', postId).single();
    final newValue = (current[reactionType] as int) + increment;

    await _client.from('posts').update({reactionType: newValue}).eq('id', postId);
  }

  Stream<List<Post>> getPostsStream() {
    return _client.from('posts').stream(primaryKey: ['id']).order('created_at', ascending: false).map(
      (data) => data.map((json) => Post.fromJson(json)).toList(),
    );
  }
}