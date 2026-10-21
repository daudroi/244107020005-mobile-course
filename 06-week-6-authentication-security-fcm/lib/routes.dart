class AppRoutes {
  static const login = '/login';
  static const home = '/';
  static const announcementDetail = '/pengumuman/:id';

  static String announcementPath(String id) => '/pengumuman/$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route']?.toString() ?? AppRoutes.home;
  if (route.isEmpty) return AppRoutes.home;
  return route.startsWith('/') ? route : '/$route';
}
