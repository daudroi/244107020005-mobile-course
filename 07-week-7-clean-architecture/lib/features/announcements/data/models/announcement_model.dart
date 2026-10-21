import '../../domain/entities/announcement.dart';

class AnnouncementModel extends Announcement {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.body,
    required super.date,
    required super.category,
    super.important = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'date': date,
        'category': category,
        'important': important,
      };

  factory AnnouncementModel.fromMap(Map<String, dynamic> map) {
    return AnnouncementModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] as String? ?? 'Pengumuman',
      body: map['body'] as String? ?? '',
      date: map['date'] as String? ?? '',
      category: map['category'] as String? ?? 'Umum',
      important: map['important'] as bool? ?? false,
    );
  }

  Announcement toEntity() => Announcement(
        id: id,
        title: title,
        body: body,
        date: date,
        category: category,
        important: important,
      );
}
