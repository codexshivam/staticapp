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
  final DateTime? listenedAt;

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
    this.listenedAt,
  });

  static List<double> generateWaveform(int count) {
    return List.generate(count, (index) {
      if (index % 5 == 0) return 0.2;
      if (index % 4 == 0) return 0.5;
      if (index % 3 == 0) return 0.8;
      if (index % 2 == 0) return 0.4;
      return 0.6;
    });
  }

  static List<Confession> generateManyMockConfessions(int count, {bool forFollowing = false}) {
    final List<String> titles = [
      'I still think about our late night talks',
      'I wish I had the courage to say sorry',
      'To the stranger I met in the coffee shop',
      'Some memories never fade away',
    ];

    return List.generate(count, (index) {
      final titleIndex = index % titles.length;
      final durationM = 1 + (index % 4);
      final durationS = 10 + (index * 13) % 49;

      return Confession(
        id: forFollowing ? 'conf_gen_f_$index' : 'conf_gen_24h_$index',
        title: titles[titleIndex],
        authorId: 'user_guest',
        createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
        durationString: '$durationM:${durationS.toString().padLeft(2, '0')}',
        durationSeconds: durationM * 60 + durationS,
        waveformData: generateWaveform(35),
        commentsCount: 2 + index,
        isSaved: index % 7 == 0,
      );
    });
  }

  static List<Confession> mockConfessions = generateManyMockConfessions(10);

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
    DateTime? listenedAt,
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
      listenedAt: listenedAt ?? this.listenedAt,
    );
  }

  factory Confession.fromJson(Map<String, dynamic> json) {
    return Confession(
      id: json['\$id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      authorId: json['authorId'] ?? '',
      createdAt: json['\$createdAt'] != null
          ? DateTime.parse(json['\$createdAt'])
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now()),
      durationString: json['durationString'] ?? '',
      durationSeconds: json['durationSeconds'] ?? 0,
      waveformData: List<double>.from(
        (json['waveformData'] ?? []).map((e) => (e as num).toDouble()),
      ),
      commentsCount: json['commentsCount'] ?? 0,
      isSaved: json['isSaved'] ?? false,
      audioUrl: json['audioUrl'],
      audioFilePath: json['audioFilePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
