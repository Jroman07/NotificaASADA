/// Notificación del backend: estructura anidada con Notification dentro.
/// {
///   Id: int (userNotificationId),
///   Is_Read: bool,
///   CreatedAt: string (ISO),
///   Notification: {
///     Id: int,
///     Subject: string,
///     Message: string,
///     CreatedAt: string (ISO)
///   }
/// }
class Notification {
  const Notification({
    required this.userNotificationId,
    required this.id,
    required this.subject,
    required this.message,
    required this.createdAt,
    required this.isRead,
  });

  final int userNotificationId;
  final int id;
  final String subject;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  factory Notification.fromJson(Map<String, dynamic> json) {
    final notif = json['Notification'];
    if (notif is! Map<String, dynamic>) {
      throw const FormatException('Estructura de notificación inválida.');
    }

    return Notification(
      userNotificationId: _readInt(json['Id']),
      id: _readInt(notif['Id']),
      subject: _readString(notif['Subject']),
      message: _readString(notif['Message']),
      createdAt: _readDateTime(notif['CreatedAt']),
      isRead: _readBool(json['Is_Read']),
    );
  }

  Map<String, dynamic> toJson() => {
        'Id': userNotificationId,
        'Notification': {
          'Id': id,
          'Subject': subject,
          'Message': message,
          'CreatedAt': createdAt.toIso8601String(),
        },
        'Is_Read': isRead,
      };

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static String _readString(dynamic value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  static DateTime _readDateTime(dynamic value) {
    if (value == null) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      return parsed ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
}
