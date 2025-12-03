class AppNotification {
  final int id;
  final String message;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.message,
    required this.createdAt,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
