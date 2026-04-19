class Reminder {
  final int id;
  final int saleId;
  final DateTime reminderDate;
  final bool isSent;
  final int? notificationId;
  final DateTime createdAt;

  Reminder({
    required this.id,
    required this.saleId,
    required this.reminderDate,
    this.isSent = false,
    this.notificationId,
    required this.createdAt,
  });

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int,
      saleId: map['sale_id'] as int,
      reminderDate: DateTime.parse(map['reminder_date'] as String),
      isSent: (map['is_sent'] as int?) == 1,
      notificationId: map['notification_id'] as int?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'reminder_date': reminderDate.toIso8601String(),
      'is_sent': isSent ? 1 : 0,
      'notification_id': notificationId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Reminder copyWith({
    int? id,
    int? saleId,
    DateTime? reminderDate,
    bool? isSent,
    int? notificationId,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      reminderDate: reminderDate ?? this.reminderDate,
      isSent: isSent ?? this.isSent,
      notificationId: notificationId ?? this.notificationId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'Reminder(saleId: $saleId, reminderDate: $reminderDate, isSent: $isSent)';
}