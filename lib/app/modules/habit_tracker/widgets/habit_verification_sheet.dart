import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/habit_log_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/habit_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/habit_icon_badge.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/app_date_formatter.dart';

class HabitVerificationSheet extends StatefulWidget {
  final HabitModel habit;

  const HabitVerificationSheet({super.key, required this.habit});

  @override
  State<HabitVerificationSheet> createState() => _HabitVerificationSheetState();
}

class _HabitVerificationSheetState extends State<HabitVerificationSheet> {
  final AuthService _authService = Get.find<AuthService>();
  final HabitService _habitService = Get.find<HabitService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _detailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late DateTime _selectedDate;
  String _selectedSubCategory = '';
  String? _photoPath;
  bool _isSaving = false;
  bool _isEditingExisting = false;
  bool _isReadOnly = false;

  final List<String> _sholatOptions = [
    'Sholat Subuh',
    'Sholat Dzuhur',
    'Sholat Ashar',
    'Sholat Maghrib',
    'Sholat Isya',
    'Sholat Dhuha',
    'Sholat Tahajud',
  ];

  final List<String> _nonMuslimOptions = [
    'Doa Pagi / Kebaktian Pagi',
    'Doa Malam / Kebaktian Malam',
    'Ibadah Mingguan / Sekolah Minggu',
    'Puja Tri Sandhya / Sembahyang',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = _habitService.selectedDate.value;
    final user = _authService.currentUser.value;
    final religion = user?.religion ?? 'Islam';
    final progress = _habitService.getPrayerProgress(religion, targetDate: _selectedDate);

    if (widget.habit.id == 'h2') {
      if (religion == 'Islam') {
        const obligatory = ['Sholat Subuh', 'Sholat Dzuhur', 'Sholat Ashar', 'Sholat Maghrib', 'Sholat Isya'];
        final uncompleted = obligatory.where((p) => !progress.completedPrayers.contains(p)).toList();
        _selectedSubCategory = uncompleted.isNotEmpty ? uncompleted.first : _sholatOptions.first;
      } else {
        _selectedSubCategory = _nonMuslimOptions.first;
      }
      _checkExistingLogForSelection(_selectedSubCategory);
    } else {
      _checkExistingLogForHabit(_selectedDate);
    }
  }

  void _checkExistingLogForHabit(DateTime date) {
    final existingLog = _habitService.getExistingLogForHabit(widget.habit.id, targetDate: date);
    if (existingLog != null) {
      setState(() {
        _isEditingExisting = true;
        _isReadOnly = true;
        _noteController.text = existingLog.note ?? '';
        _detailController.text = existingLog.detailType ?? '';
        _photoPath = existingLog.photoUrl;
      });
    } else {
      setState(() {
        _isEditingExisting = false;
        _isReadOnly = false;
        _noteController.clear();
        _detailController.clear();
        _photoPath = null;
      });
    }
  }

  void _checkExistingLogForSelection(String selectedOption) {
    final existingLog = _habitService.getExistingLogForPrayer(selectedOption, targetDate: _selectedDate);

    if (existingLog != null) {
      _populateFieldsWithLog(existingLog, selectedOption, isReadOnly: true);
    } else {
      setState(() {
        _selectedSubCategory = selectedOption;
        _isEditingExisting = false;
        _isReadOnly = false;
        _noteController.clear();
        _detailController.clear();
        _photoPath = null;
      });
    }
  }

  void _populateFieldsWithLog(HabitLogModel log, String selectedOption, {bool isReadOnly = true}) {
    setState(() {
      _selectedSubCategory = selectedOption;
      _isEditingExisting = true;
      _isReadOnly = isReadOnly;
      _noteController.text = log.note ?? '';
      _detailController.text = log.detailType ?? '';
      _photoPath = log.photoUrl;
    });
  }

  void _requestEnableEditMode() {
    Get.defaultDialog(
      title: 'Ubah Data Jurnal? 📝',
      middleText: 'Apakah Anda yakin ingin mengubah isi jurnal yang telah tersimpan untuk ${widget.habit.id == 'h2' ? _selectedSubCategory : widget.habit.title} tanggal ${DateFormat('dd MMM yyyy').format(_selectedDate)}?',
      textConfirm: 'Ya, Ubah Data',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        setState(() {
          _isReadOnly = false;
        });
        Get.snackbar(
          'Mode Edit Aktif ✏️',
          'Silakan perbarui catatan atau foto bukti Anda, lalu klik Simpan Perubahan.',
          backgroundColor: Colors.teal.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _deleteHabitLog() {
    Get.defaultDialog(
      title: 'Hapus Jurnal Kebiasaan? 🗑️',
      middleText: 'Apakah Anda yakin ingin menghapus catatan kebiasaan ${widget.habit.id == 'h2' ? _selectedSubCategory : widget.habit.title} tanggal ${DateFormat('dd MMM yyyy').format(_selectedDate)}? Progress akan kembali 0.',
      textConfirm: 'Ya, Hapus Jurnal',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        if (widget.habit.id == 'h2') {
          final uid = _authService.currentUser.value?.id ?? _habitService.activeStudentId;
          final target = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
          _habitService.habitLogs.removeWhere(
            (log) => log.habitId == 'h2' && _habitService.isSameDay(log.date, target) && log.detailType == _selectedSubCategory && _habitService.isUserMatch(log.userId, uid),
          );
          await _habitService.saveLogsToStorage();
          _habitService.refreshHabitsForSelectedDate();
        } else {
          await _habitService.removeHabitLog(widget.habit.id, _selectedDate);
        }
        Get.back();
        Get.snackbar(
          'Jurnal Dihapus 🗑️',
          'Catatan kebiasaan telah dihapus dan progress ter-reset ke 0.',
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  void _pickPhoto() {
    if (_isReadOnly) return;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const FaIcon(FontAwesomeIcons.camera, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unggah Foto Bukti 📷',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Pilih metode pengambilan foto bukti Anda',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: FaIcon(FontAwesomeIcons.camera, color: Colors.teal.shade700, size: 20),
              ),
              title: const Text('Ambil Foto Kamera 📸', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Buka kamera hp / emulator secara langsung'),
              onTap: () {
                Get.back();
                _pickImageWithSource(ImageSource.camera);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const FaIcon(FontAwesomeIcons.image, color: Colors.indigo, size: 20),
              ),
              title: const Text('Pilih dari Galeri / File 🖼️', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Pilih file foto dari memori galeri'),
              onTap: () {
                Get.back();
                _pickImageWithSource(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageWithSource(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (photo != null) {
        setState(() {
          _photoPath = photo.path;
        });
      }
    } catch (e) {
      if (source == ImageSource.camera) {
        try {
          final XFile? photo = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 70,
            maxWidth: 1024,
          );
          if (photo != null) {
            setState(() {
              _photoPath = photo.path;
            });
          }
          return;
        } catch (_) {}
      }

      Get.snackbar(
        'Gagal Membuka Kamera',
        'Pastikan izin kamera dan galeri telah diberikan',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  bool _isPhotoMandatory() {
    return widget.habit.id == 'h2' || widget.habit.id == 'h5';
  }

  void _submitVerification() async {
    if (_isPhotoMandatory() && (_photoPath == null || _photoPath!.isEmpty)) {
      Get.snackbar(
        'Foto Bukti Wajib 📷',
        'Khusus kebiasaan Beribadah dan Gemar Belajar, Anda wajib mengambil foto bukti!',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (widget.habit.id == 'h5' && _detailController.text.trim().isEmpty) {
      Get.snackbar(
        'Judul Buku Wajib Isi 📚',
        'Silakan tulis judul buku atau mata pelajaran yang dipelajari',
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSaving = true);

    await Future.delayed(const Duration(milliseconds: 400));

    final user = _authService.currentUser.value;
    final religion = user?.religion ?? 'Islam';

    final log = HabitLogModel(
      id: 'log-${DateTime.now().millisecondsSinceEpoch}',
      habitId: widget.habit.id,
      userId: user?.id ?? 'usr-1',
      date: _selectedDate,
      isCompleted: true,
      note: _noteController.text.trim().isEmpty
          ? 'Terselesaikan & Diverifikasi pada ${DateFormat('HH:mm').format(DateTime.now())}'
          : _noteController.text.trim(),
      photoUrl: _photoPath,
      detailType: widget.habit.id == 'h2' ? _selectedSubCategory : _detailController.text.trim(),
      earnedPoints: widget.habit.points,
    );

    _habitService.addOrUpdateHabitLog(log, religion: religion);

    setState(() => _isSaving = false);

    Get.back();

    if (widget.habit.id == 'h2') {
      final updatedProgress = _habitService.getPrayerProgress(religion, targetDate: _selectedDate);
      Get.snackbar(
        _isEditingExisting ? 'Pembaruan Berhasil! 🔄' : 'Bukti $_selectedSubCategory Tersimpan! 🎉',
        updatedProgress.isAllCompleted
            ? 'Hebat! Anda telah menyelesaikan seluruh 5 waktu ibadah untuk tanggal ${DateFormat('dd MMM').format(_selectedDate)} (+10 Pts)'
            : 'Progress Ibadah: ${updatedProgress.displayProgress}. Tetap laksanakan sholat berikutnya ya!',
        backgroundColor: AppColors.primaryDark,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    } else {
      Get.snackbar(
        'Verifikasi Berhasil! 🎉',
        'Selamat, Anda mendapatkan +${widget.habit.points} Poin Kebaikan!',
        backgroundColor: AppColors.primaryDark,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser.value;
    final religion = user?.religion ?? 'Islam';
    final prayerProgress = _habitService.getPrayerProgress(religion, targetDate: _selectedDate);
    final isToday = _habitService.isSameDay(_selectedDate, DateTime.now());
    final dateDisplay = isToday
        ? 'Hari Ini (${AppDateFormatter.formatIndonesian(_selectedDate, 'EEEE, d MMMM yyyy')})'
        : AppDateFormatter.formatIndonesian(_selectedDate, 'EEEE, d MMMM yyyy');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sheet Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Close with HabitIconBadge
            Row(
              children: [
                HabitIconBadge(
                  habitId: widget.habit.id,
                  iconName: widget.habit.iconName,
                  religion: religion,
                  size: 46,
                  showBadge: false,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bukti Kebiasaan Baik • $dateDisplay',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        widget.habit.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const FaIcon(FontAwesomeIcons.xmark, color: AppColors.textSecondary, size: 18),
                ),
              ],
            ),
            const Divider(height: 20),

            // PRAYER PROGRESS DISPLAY FOR IBADAH (h2)
            if (widget.habit.id == 'h2') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: prayerProgress.isAllCompleted
                      ? Colors.teal.shade50
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: prayerProgress.isAllCompleted
                        ? Colors.teal.shade300
                        : Colors.blue.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FaIcon(
                              prayerProgress.isAllCompleted
                                  ? FontAwesomeIcons.solidCircleCheck
                                  : FontAwesomeIcons.clock,
                              color: prayerProgress.isAllCompleted
                                  ? Colors.teal.shade700
                                  : Colors.blue.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              religion == 'Islam' ? 'Progress Sholat 5 Waktu' : 'Progress Ibadah Harian',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: prayerProgress.isAllCompleted
                                    ? Colors.teal.shade900
                                    : Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: prayerProgress.isAllCompleted
                                ? Colors.teal.shade700
                                : Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            prayerProgress.displayProgress,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Chips for 5 obligatory prayers if Islam
                    if (religion == 'Islam')
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ['Sholat Subuh', 'Sholat Dzuhur', 'Sholat Ashar', 'Sholat Maghrib', 'Sholat Isya'].map((prayer) {
                          final isDone = prayerProgress.completedPrayers.contains(prayer);
                          final isSelected = _selectedSubCategory == prayer;

                          return GestureDetector(
                            onTap: () => _checkExistingLogForSelection(prayer),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDone
                                    ? (isSelected ? Colors.teal.shade800 : Colors.teal.shade600)
                                    : (isSelected ? Colors.blue.shade100 : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDone ? Colors.teal.shade700 : Colors.blue.shade200),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FaIcon(
                                    isDone ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circle,
                                    size: 12,
                                    color: isDone ? Colors.white : Colors.blue.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    prayer.replaceFirst('Sholat ', ''),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isDone ? Colors.white : Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dropdown for Selecting Prayer
              Text(
                religion == 'Islam' ? 'Pilih Waktu Sholat *' : 'Pilih Jenis / Waktu Ibadah *',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: _selectedSubCategory,
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FaIcon(FontAwesomeIcons.handsPraying, color: AppColors.primary, size: 16),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: (religion == 'Islam' ? _sholatOptions : _nonMuslimOptions).map((option) {
                  final isAlreadyDone = prayerProgress.completedPrayers.contains(option);
                  return DropdownMenuItem(
                    value: option,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(option),
                        if (isAlreadyDone)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('✓ Sudah Tersimpan', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null && val != _selectedSubCategory) {
                    _checkExistingLogForSelection(val);
                  }
                },
              ),
              const SizedBox(height: 14),
            ],

            // READ ONLY STATUS BANNER
            if (_isReadOnly)
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.lock, size: 14, color: Color(0xFFB45309)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Jurnal ini telah tersimpan (Mode Baca). Klik "Ubah Data Jurnal" di bawah untuk melakukan perubahan.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // FIELD FOR GEMAR BELAJAR (h5)
            if (widget.habit.id == 'h5') ...[
              CustomTextField(
                controller: _detailController,
                labelText: 'Judul Buku / Mata Pelajaran *',
                hintText: 'Contoh: Buku Pemrograman Dart / Fisika Bab 3',
                prefixIcon: Icons.book_rounded,
                readOnly: _isReadOnly,
              ),
              const SizedBox(height: 14),
            ],

            // PENJELASAN & CATATAN KEGIATAN
            Text(
              widget.habit.id == 'h5'
                  ? 'Ringkasan Apa yang Dibaca / Dipelajari *'
                  : 'Penjelasan & Catatan Kegiatan (Opsional)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),

            TextFormField(
              controller: _noteController,
              readOnly: _isReadOnly,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: widget.habit.id == 'h5'
                    ? 'Tuliskan poin utama atau rangkuman yang kamu pahami...'
                    : 'Tuliskan catatan refleksi singkat kegiatan ini...',
                filled: true,
                fillColor: _isReadOnly ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),

            // UNGGAH FOTO BUKTI (MANDATORY FOR IBADAH & GEMAR BELAJAR)
            Row(
              children: [
                Text(
                  _isPhotoMandatory() ? 'Unggah Foto Bukti (Wajib *)' : 'Unggah Foto Bukti (Opsional)',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                if (_isPhotoMandatory()) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Foto Wajib',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade900),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            if (_photoPath != null && _photoPath!.isNotEmpty)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_photoPath!),
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (!_isReadOnly)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          icon: const FaIcon(FontAwesomeIcons.xmark, color: Colors.white, size: 16),
                          onPressed: () => setState(() => _photoPath = null),
                        ),
                      ),
                    )
                  else
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            FaIcon(FontAwesomeIcons.circleCheck, color: Colors.white, size: 12),
                            SizedBox(width: 6),
                            Text(
                              'Foto Bukti Tersimpan',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            else if (_isReadOnly)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  children: [
                    FaIcon(FontAwesomeIcons.image, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 10),
                    Text(
                      'Belum ada foto bukti yang dilampirkan.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              )
            else
              InkWell(
                onTap: _pickPhoto,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _isPhotoMandatory() ? Colors.red.shade50 : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isPhotoMandatory() ? Colors.red.shade300 : const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.camera,
                        color: _isPhotoMandatory() ? Colors.red.shade700 : AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isPhotoMandatory() ? '📷 Buka Kamera & Foto Bukti (Wajib)' : '📷 Ambil Foto Langsung (Kamera)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _isPhotoMandatory() ? Colors.red.shade700 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // SUBMIT / EDIT BUTTON
            if (_isReadOnly)
              CustomButton(
                text: '✏️ Ubah Data Jurnal Ini',
                isLoading: false,
                onPressed: _requestEnableEditMode,
                icon: Icons.edit_note_rounded,
              )
            else
              CustomButton(
                text: widget.habit.id == 'h2'
                    ? (_isEditingExisting ? 'Simpan Perubahan $_selectedSubCategory' : 'Simpan Bukti $_selectedSubCategory')
                    : (_isEditingExisting ? 'Simpan Perubahan Kebiasaan' : 'Simpan & Verifikasi Kebiasaan'),
                isLoading: _isSaving,
                onPressed: _submitVerification,
                icon: _isEditingExisting ? Icons.sync_rounded : Icons.check_circle_rounded,
              ),

            if (_isEditingExisting || _isReadOnly) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _deleteHabitLog,
                  icon: const FaIcon(FontAwesomeIcons.trashCan, size: 14, color: Colors.red),
                  label: Text(
                    widget.habit.id == 'h2'
                        ? 'Hapus / Reset Jurnal $_selectedSubCategory Tanggal Ini'
                        : 'Hapus / Reset Kebiasaan Ini (Kembali 0)',
                    style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
