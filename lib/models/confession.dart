class Confession {
  final String id;
  final String title;
  final String authorName;
  final String authorHandle;
  final String authorId;
  final String timestamp;
  final String durationString;
  final int durationSeconds;
  final List<double> waveformData;
  final int likesCount;
  final int commentsCount;
  final bool isSaved;
  final String dateText;

  const Confession({
    required this.id,
    required this.title,
    required this.authorName,
    required this.authorHandle,
    required this.authorId,
    required this.timestamp,
    required this.durationString,
    required this.durationSeconds,
    required this.waveformData,
    required this.likesCount,
    required this.commentsCount,
    required this.isSaved,
    required this.dateText,
  });

  Confession copyWith({
    String? id,
    String? title,
    String? authorName,
    String? authorHandle,
    String? authorId,
    String? timestamp,
    String? durationString,
    int? durationSeconds,
    List<double>? waveformData,
    int? likesCount,
    int? commentsCount,
    bool? isSaved,
    String? dateText,
  }) {
    return Confession(
      id: id ?? this.id,
      title: title ?? this.title,
      authorName: authorName ?? this.authorName,
      authorHandle: authorHandle ?? this.authorHandle,
      authorId: authorId ?? this.authorId,
      timestamp: timestamp ?? this.timestamp,
      durationString: durationString ?? this.durationString,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      waveformData: waveformData ?? this.waveformData,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isSaved: isSaved ?? this.isSaved,
      dateText: dateText ?? this.dateText,
    );
  }
}
