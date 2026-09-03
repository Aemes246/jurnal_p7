class TeacherNoteModel {
  final String id;
  final String studentId;
  final String teacherId;
  final String teacherName;
  final DateTime date;
  final String note;
  final DateTime? createdAt;

  TeacherNoteModel({
    required this.id,
    required this.studentId,
    required this.teacherId,
    this.teacherName = '',
    required this.date,
    required this.note,
    this.createdAt,
  });

  factory TeacherNoteModel.fromJson(Map<String, dynamic> json) {
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

    return TeacherNoteModel(
      id: json['id'] ?? '',
      studentId: json['student_id'] ?? '',
      teacherId: json['teacher_id'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      date: parsedDate,
      note: json['note'] ?? '',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'date': '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'note': note,
    };
  }
}
