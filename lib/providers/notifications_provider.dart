import 'package:flutter/material.dart';
import '../services/notifications_service.dart';
import '../models/notifications.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService service;
  List<AppNotification> _notifications = [];
  bool _loading = false;

  NotificationProvider({required this.service}) {
    fetchNotifications();
  }

  List<AppNotification> get notifications => _notifications;
  bool get loading => _loading;

  Future<void> fetchNotifications() async {
    _loading = true;
    notifyListeners();

    try {
      _notifications = await service.getNotifications();
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchNotifications();
  }
}
