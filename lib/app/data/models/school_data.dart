class StudentRecord {
  final String nis;
  final String nisn;
  final String name;
  final String className;
  final String homeroomTeacher;
  final String phone;

  const StudentRecord({
    required this.nis,
    required this.nisn,
    required this.name,
    required this.className,
    required this.homeroomTeacher,
    this.phone = '0812-3456-7890',
  });
}

class TeacherRecord {
  final String name;
  final String email;
  final String assignedClass;
  final String phone;
  final String nip;

  const TeacherRecord({
    required this.name,
    required this.email,
    required this.assignedClass,
    this.phone = '0812-5555-7701',
    this.nip = '-',
  });
}

class SchoolData {
  // All master data (classes, teachers, students, assignments) are loaded 100% online
  // from Supabase Cloud Database tables (`classes`, `teachers`, `students`).
  // Zero hardcoded static const lists.
}
