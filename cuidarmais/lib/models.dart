enum UserRole { elder, caregiver }

enum ReminderType { medicine, appointment, activity, meal, other }

enum ReminderAlertMode { notification, alarm }

enum ReminderStatus { pending, confirmed, delayed, missed }

enum CommunityActivityCategory {
  social,
  wellbeing,
  culture,
  exercise,
  learning,
}

enum ActivitySubmissionStatus { pendingReview, approved, rejected }

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
    this.communityActivityId,
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
  final String? communityActivityId;
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

class CommunityActivity {
  CommunityActivity({
    required this.id,
    required this.title,
    required this.organizer,
    required this.description,
    required this.category,
    required this.address,
    required this.phone,
    required this.scheduleLabel,
    required this.weekday,
    required this.hour,
    required this.minute,
    required this.audience,
    required this.priceLabel,
    required this.accessibilityLabel,
    required this.verifiedAt,
    required this.sourceUrl,
    this.startDate,
    this.endDate,
    this.requiresRegistration = true,
  });

  final String id;
  final String title;
  final String organizer;
  final String description;
  final CommunityActivityCategory category;
  final String address;
  final String phone;
  final String scheduleLabel;
  final int weekday;
  final int hour;
  final int minute;
  final String audience;
  final String priceLabel;
  final String accessibilityLabel;
  final DateTime verifiedAt;
  final String sourceUrl;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool requiresRegistration;

  String get categoryLabel => switch (category) {
    CommunityActivityCategory.social => 'Convivência',
    CommunityActivityCategory.wellbeing => 'Bem-estar',
    CommunityActivityCategory.culture => 'Cultura',
    CommunityActivityCategory.exercise => 'Movimento',
    CommunityActivityCategory.learning => 'Aprendizado',
  };

  String get formattedVerifiedAt {
    final day = verifiedAt.day.toString().padLeft(2, '0');
    final month = verifiedAt.month.toString().padLeft(2, '0');
    return '$day/$month/${verifiedAt.year}';
  }

  DateTime? nextOccurrence([DateTime? reference]) {
    final now = reference ?? DateTime.now();
    var candidate = DateTime(now.year, now.month, now.day, hour, minute);
    final daysUntil = (weekday - candidate.weekday + 7) % 7;
    candidate = candidate.add(Duration(days: daysUntil));
    if (!candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    final starts = startDate;
    while (starts != null && candidate.isBefore(starts)) {
      candidate = candidate.add(const Duration(days: 7));
    }
    final ends = endDate;
    if (ends != null && candidate.isAfter(ends)) return null;
    return candidate;
  }
}

class ActivitySubmission {
  ActivitySubmission({
    required this.id,
    required this.organizer,
    required this.contact,
    required this.title,
    required this.schedule,
    required this.address,
    required this.description,
    required this.submittedAt,
    this.status = ActivitySubmissionStatus.pendingReview,
  });

  final int id;
  final String organizer;
  final String contact;
  final String title;
  final String schedule;
  final String address;
  final String description;
  final DateTime submittedAt;
  ActivitySubmissionStatus status;

  String get protocol => 'CM-${id.toString().padLeft(4, '0')}';

  String get statusLabel => switch (status) {
    ActivitySubmissionStatus.pendingReview => 'Aguardando verificação',
    ActivitySubmissionStatus.approved => 'Aprovada',
    ActivitySubmissionStatus.rejected => 'Não aprovada',
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
