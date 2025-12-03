
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notifications.dart';

class NotificationService {
  final SupabaseClient supabase;

  NotificationService({required this.supabase});

  Future<List<AppNotification>> getNotifications() async {
    final response = await supabase
        .from('notifications')
        .select()
        .order('created_at', ascending: false);

    if (response.isEmpty) {
      return [];
    }

    final data = response as List<dynamic>;
    return data.map((e) => AppNotification.fromMap(e)).toList();
  }
}
