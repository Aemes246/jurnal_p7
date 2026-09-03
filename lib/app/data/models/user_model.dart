class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final String role; // 'siswa', 'guru', 'superadmin'
  final String religion; // 'Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Khonghucu'
  
  // Data Master Terikat dari Sekolah / Superadmin
  final String? nis;
  final String? nisn;
  final String? className;
  final String? nip;
  final String? phone;

  // Data biodata "Ayo Berkenalan!" (Diisi Siswa)
  final String? address; // Saya tinggal di
  final String? hobby; // Hobi saya
  final String? ambition; // Cita-cita saya
  final String? favoriteSport; // Olahraga Kesukaan
  final String? favoriteFood; // Makanan kesukaan
  final String? favoriteSubject; // Mata Pelajaran Favorit
  final String? uniqueness; // Keunikan Saya Yaitu
  final String? homeroomTeacher; // Nama Guru Wali Pembina
  final String? waliKelas; // Nama Wali Kelas Rombel
  final String? homeroomTeacherSignature; // TTD Guru Wali

  final bool isProfileCompleted;
  final int totalStreak;
  final int totalPoints;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.role = 'siswa',
    this.religion = 'Islam',
    this.nis,
    this.nisn,
    this.className,
    this.nip,
    this.phone,
    this.address,
    this.hobby,
    this.ambition,
    this.favoriteSport,
    this.favoriteFood,
    this.favoriteSubject,
    this.uniqueness,
    this.homeroomTeacher,
    this.waliKelas,
    this.homeroomTeacherSignature,
    this.isProfileCompleted = false,
    this.totalStreak = 0,
    this.totalPoints = 0,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? 'Pengguna',
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'siswa',
      religion: json['religion'] ?? 'Islam',
      nis: json['nis'],
      nisn: json['nisn'],
      className: json['class_name'],
      nip: json['nip'],
      phone: json['phone'],
      address: json['address'],
      hobby: json['hobby'],
      ambition: json['ambition'],
      favoriteSport: json['favorite_sport'],
      favoriteFood: json['favorite_food'],
      favoriteSubject: json['favorite_subject'],
      uniqueness: json['uniqueness'],
      homeroomTeacher: json['homeroom_teacher'],
      waliKelas: json['wali_kelas'],
      homeroomTeacherSignature: json['homeroom_teacher_signature'],
      isProfileCompleted: json['is_profile_completed'] ?? false,
      totalStreak: json['total_streak'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'role': role,
      'religion': religion,
      'nis': nis,
      'nisn': nisn,
      'class_name': className,
      'nip': nip,
      'phone': phone,
      'address': address,
      'hobby': hobby,
      'ambition': ambition,
      'favorite_sport': favoriteSport,
      'favorite_food': favoriteFood,
      'favorite_subject': favoriteSubject,
      'uniqueness': uniqueness,
      'homeroom_teacher': homeroomTeacher,
      'wali_kelas': waliKelas,
      'homeroom_teacher_signature': homeroomTeacherSignature,
      'is_profile_completed': isProfileCompleted,
      'total_streak': totalStreak,
      'total_points': totalPoints,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    String? role,
    String? religion,
    String? nis,
    String? nisn,
    String? className,
    String? nip,
    String? phone,
    String? address,
    String? hobby,
    String? ambition,
    String? favoriteSport,
    String? favoriteFood,
    String? favoriteSubject,
    String? uniqueness,
    String? homeroomTeacher,
    String? waliKelas,
    String? homeroomTeacherSignature,
    bool? isProfileCompleted,
    int? totalStreak,
    int? totalPoints,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      religion: religion ?? this.religion,
      nis: nis ?? this.nis,
      nisn: nisn ?? this.nisn,
      className: className ?? this.className,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      hobby: hobby ?? this.hobby,
      ambition: ambition ?? this.ambition,
      favoriteSport: favoriteSport ?? this.favoriteSport,
      favoriteFood: favoriteFood ?? this.favoriteFood,
      favoriteSubject: favoriteSubject ?? this.favoriteSubject,
      uniqueness: uniqueness ?? this.uniqueness,
      homeroomTeacher: homeroomTeacher ?? this.homeroomTeacher,
      waliKelas: waliKelas ?? this.waliKelas,
      homeroomTeacherSignature: homeroomTeacherSignature ?? this.homeroomTeacherSignature,
      isProfileCompleted: isProfileCompleted ?? this.isProfileCompleted,
      totalStreak: totalStreak ?? this.totalStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
