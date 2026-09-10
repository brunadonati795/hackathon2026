enum UserRole { elder, caregiver }

enum ReminderType { medicine, appointment, activity, meal, other }

enum ReminderAlertMode { notification, alarm }

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
    this.scheduledDate,
    this.photoPath,
    this.audioPath,
    this.customType,
    this.alertMode = ReminderAlertMode.alarm,
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
  final DateTime? scheduledDate;
  final String? photoPath;
  final String? audioPath;
  final String? customType;
  final ReminderAlertMode alertMode;
  ReminderStatus status;
  final bool isDaily;

  String get formattedDate {
    final date = scheduledDate;
    if (date == null) return 'Sem data definida';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String get typeLabel => switch (type) {
    ReminderType.medicine => 'Remédio',
    ReminderType.appointment => 'Consulta',
    ReminderType.activity => 'Atividade',
    ReminderType.meal => 'Refeição',
    ReminderType.other =>
      customType?.trim().isNotEmpty == true ? customType!.trim() : 'Outro',
  };

  String get alertModeLabel => switch (alertMode) {
    ReminderAlertMode.notification => 'Notificação',
    ReminderAlertMode.alarm => 'Alarme',
  };
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
