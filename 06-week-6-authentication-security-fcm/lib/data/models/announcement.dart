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

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Pengumuman Tanpa Judul',
      body: json['body'] as String? ?? '',
      date: json['date'] as String? ?? '',
      category: json['category'] as String? ?? 'Umum',
      important: json['important'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date,
        'category': category,
        'important': important,
      };
}
