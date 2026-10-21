class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
    required this.category,
    this.important = false,
  });

  final String id;
  final String title;
  final String body;
  final String date;
  final String category;
  final bool important;
}
