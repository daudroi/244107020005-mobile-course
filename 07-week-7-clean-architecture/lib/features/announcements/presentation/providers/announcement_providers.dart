import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/usecases/get_announcements.dart';

// Data layer DI
final announcementRepositoryProvider =
    Provider<AnnouncementRepository>((ref) {
  return AnnouncementRepositoryImpl();
});

// Domain layer DI
final getAnnouncementsProvider = Provider<GetAnnouncements>((ref) {
  return GetAnnouncements(ref.watch(announcementRepositoryProvider));
});

// Presentation layer state
final announcementsProvider =
    FutureProvider<List<Announcement>>((ref) async {
  final usecase = ref.watch(getAnnouncementsProvider);
  final result = await usecase.call();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.announcements;
});
