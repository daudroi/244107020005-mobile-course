import '../../../../core/failures.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementRepositoryImpl implements AnnouncementRepository {
  static const List<AnnouncementModel> _announcements = [
    AnnouncementModel(
      id: '1',
      title: 'Perubahan Jadwal Kuliah Pemrograman Mobile',
      body: 'Kelas Pemrograman Mobile TI 3F hari Kamis dipindahkan ke Ruang A2 pada pukul 13.00 WIB.',
      date: '2026-10-20',
      category: 'Akademik',
      important: true,
    ),
    AnnouncementModel(
      id: '2',
      title: 'Pendaftaran Ujian Tengah Semester (UTS)',
      body: 'Mahasiswa diharapkan memverifikasi KRS online dan menyelesaikan administrasi sebelum pekan UTS.',
      date: '2026-10-18',
      category: 'Akademik',
      important: false,
    ),
    AnnouncementModel(
      id: '3',
      title: 'Kuliah Tamu: Clean Architecture & SOLID Principles',
      body: 'Seminar hybrid bersama software architect membahas feature-first structure, domain independence, dan dependency inversion.',
      date: '2026-10-15',
      category: 'Event Kampus',
      important: true,
    ),
  ];

  @override
  Future<({List<Announcement> announcements, Failure? failure})>
      fetchAnnouncements() async {
    try {
      final list = _announcements.map((m) => m.toEntity()).toList();
      return (announcements: list, failure: null);
    } catch (e) {
      return (
        announcements: const <Announcement>[],
        failure: LocalFailure('Gagal memuat pengumuman: $e'),
      );
    }
  }
}
