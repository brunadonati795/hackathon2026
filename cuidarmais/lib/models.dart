enum UserRole { elder, caregiver }

enum ReminderType { medicine, appointment, activity, meal }

enum ReminderStatus { pending, confirmed, delayed, missed }

class Account {
  Account({
    required this.name,
    required this.contact,
    required this.password,
    required this.role,
    this.linkKey,
    this.linkedElderKey,
  });

  final String name;
  final String contact;
  final String password;
  final UserRole role;
  final String? linkKey;
  String? linkedElderKey;
}

class CareReminder {
  CareReminder({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    required this.instructions,
    required this.createdBy,
    this.elderKey,
    this.status = ReminderStatus.pending,
    this.isDaily = false,
  });

  final int id;
  final String title;
  final String time;
  final ReminderType type;
  final String instructions;
  final String createdBy;
  final String? elderKey;
  ReminderStatus status;
  final bool isDaily;
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.targetRole,
    this.elderKey,
    this.reminderId,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String message;
  final DateTime timestamp;
  final UserRole targetRole;
  final String? elderKey;
  final int? reminderId;
  bool isRead;
}
