class Confession {
  final String id;
  final String title;
  final String authorId;
  final DateTime createdAt;
  final String durationString;
  final int durationSeconds;
  final List<double> waveformData;
  final int commentsCount;
  final bool isSaved;
  final String? audioUrl;
  final String? audioFilePath;

  const Confession({
    required this.id,
    required this.title,
    required this.authorId,
    required this.createdAt,
    required this.durationString,
    required this.durationSeconds,
    required this.waveformData,
    required this.commentsCount,
    required this.isSaved,
    this.audioUrl,
    this.audioFilePath,
  });

  Confession copyWith({
    String? id,
    String? title,
    String? authorId,
    DateTime? createdAt,
    String? durationString,
    int? durationSeconds,
    List<double>? waveformData,
    int? commentsCount,
    bool? isSaved,
    String? audioUrl,
    String? audioFilePath,
  }) {
    return Confession(
      id: id ?? this.id,
      title: title ?? this.title,
      authorId: authorId ?? this.authorId,
      createdAt: createdAt ?? this.createdAt,
      durationString: durationString ?? this.durationString,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      waveformData: waveformData ?? this.waveformData,
      commentsCount: commentsCount ?? this.commentsCount,
      isSaved: isSaved ?? this.isSaved,
      audioUrl: audioUrl ?? this.audioUrl,
      audioFilePath: audioFilePath ?? this.audioFilePath,
    );
  }

  factory Confession.fromJson(Map<String, dynamic> json) {
    return Confession(
      id: json['\$id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      authorId: json['authorId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      durationString: json['durationString'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      waveformData: List<double>.from((json['waveformData'] ?? []).map((e) => (e as num).toDouble())),
      commentsCount: json['commentsCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
      audioUrl: json['audioUrl'],
      audioFilePath: json['audioFilePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authorId': authorId,
      'createdAt': createdAt.toIso8601String(),
      'durationString': durationString,
      'durationSeconds': durationSeconds,
      'waveformData': waveformData,
      'commentsCount': commentsCount,
      'isSaved': isSaved,
      'audioUrl': audioUrl,
    };
  }
}
