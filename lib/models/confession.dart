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
  final String? audioUrl;
  final String? audioFilePath;
  final List<String> likedBy;

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
    this.audioUrl,
    this.audioFilePath,
    this.likedBy = const [],
  });

  bool isLikedBy(String userId) => likedBy.contains(userId);

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
    String? audioUrl,
    String? audioFilePath,
    List<String>? likedBy,
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
      audioUrl: audioUrl ?? this.audioUrl,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  factory Confession.fromJson(Map<String, dynamic> json) {
    return Confession(
      id: json['\$id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      authorName: json['authorName'] ?? '',
      authorHandle: json['authorHandle'] ?? '',
      authorId: json['authorId'] ?? '',
      timestamp: json['timestamp'] ?? '',
      durationString: json['durationString'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      waveformData: List<double>.from((json['waveformData'] ?? []).map((e) => (e as num).toDouble())),
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
      dateText: json['dateText'] ?? '',
      audioUrl: json['audioUrl'],
      audioFilePath: json['audioFilePath'],
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authorName': authorName,
      'authorHandle': authorHandle,
      'authorId': authorId,
      'timestamp': timestamp,
      'durationString': durationString,
      'durationSeconds': durationSeconds,
      'waveformData': waveformData,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'isSaved': isSaved,
      'dateText': dateText,
      'audioUrl': audioUrl,
      'likedBy': likedBy,
    };
  }
}
