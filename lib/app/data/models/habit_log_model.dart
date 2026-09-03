class HabitLogModel {
  final String id;
  final String habitId;
  final String habitTitle;
  final String userId;
  final DateTime date;
  final bool isCompleted;
  final String? detailType; // e.g. 'Sholat Dzuhur', 'Buku Fisika Bab 3'
  final String? note; // Penjelasan ringkasan / catatan
  final String? photoUrl; // Bukti foto kegiatan
  final String? religion;
  final int earnedPoints;

  HabitLogModel({
    required this.id,
    required this.habitId,
    this.habitTitle = '',
    required this.userId,
    required this.date,
    required this.isCompleted,
    this.detailType,
    this.note,
    this.photoUrl,
    this.religion,
    this.earnedPoints = 10,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['date'] != null) {
      final rawDate = json['date'].toString();
      try {
        final cleanDateStr = rawDate.contains('T') ? rawDate.split('T').first : rawDate;
        final parts = cleanDateStr.split('-');
        if (parts.length == 3) {
          parsedDate = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
        } else {
          parsedDate = DateTime.parse(rawDate).toLocal();
        }
      } catch (_) {
        parsedDate = DateTime.now();
      }
    }
    return HabitLogModel(
      id: json['id'] ?? '',
      habitId: json['habit_id'] ?? '',
      habitTitle: json['habit_title'] ?? '',
      userId: json['user_id'] ?? '',
      date: parsedDate,
      isCompleted: json['is_completed'] ?? false,
      detailType: json['detail_type'],
      note: json['note'],
      photoUrl: json['photo_url'],
      religion: json['religion'],
      earnedPoints: json['earned_points'] ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'habit_title': habitTitle,
      'user_id': userId,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'is_completed': isCompleted,
      'detail_type': detailType,
      'note': note,
      'photo_url': photoUrl,
      'religion': religion,
      'earned_points': earnedPoints,
    };
  }
}
