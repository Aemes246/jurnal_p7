class HabitModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'ibadah', 'belajar', 'kesehatan', 'kedisiplinan'
  final String iconName; // e.g. 'book', 'heart', 'star', 'sun'
  final int points;
  final int currentStreak;
  final bool isCompletedToday;
  final String targetFrequency; // e.g. 'Harian', 'Mingguan'

  HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
    this.points = 10,
    this.currentStreak = 0,
    this.isCompletedToday = false,
    this.targetFrequency = 'Harian',
  });

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'ibadah',
      iconName: json['icon_name'] ?? 'star',
      points: json['points'] ?? 10,
      currentStreak: json['current_streak'] ?? 0,
      isCompletedToday: json['is_completed_today'] ?? false,
      targetFrequency: json['target_frequency'] ?? 'Harian',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon_name': iconName,
      'points': points,
      'current_streak': currentStreak,
      'is_completed_today': isCompletedToday,
      'target_frequency': targetFrequency,
    };
  }

  HabitModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? iconName,
    int? points,
    int? currentStreak,
    bool? isCompletedToday,
    String? targetFrequency,
  }) {
    return HabitModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      points: points ?? this.points,
      currentStreak: currentStreak ?? this.currentStreak,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      targetFrequency: targetFrequency ?? this.targetFrequency,
    );
  }
}
