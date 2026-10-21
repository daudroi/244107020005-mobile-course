import 'package:go_router/go_router.dart';
import 'features/announcements/presentation/pages/announcements_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const NotesPage(),
    ),
    GoRoute(
      path: '/announcements',
      builder: (context, state) => const AnnouncementsPage(),
    ),
  ],
);
