import '../models/user.dart';
import '../models/confession.dart';
import '../models/comment.dart';

class SampleData {
  SampleData._();

  static AppUser currentUser = const AppUser(
    id: 'user_current',
    displayName: 'Shivam Yadav',
    handle: '@shivamyadav',
    bio: 'Listening to raw stories and sharing my voice.',
    followersCount: 148,
    followingCount: 92,
    confessionCount: 3,
    upiId: 'shivam@upi',
    links: [
      'https://shivam.dev/diary',
      'https://instagram.com/silent_letters',
    ],
  );

  static List<AppUser> mockUsers = [
    const AppUser(
      id: 'author_1',
      displayName: 'Aria Mitchell',
      handle: '@aria_m',
      bio: 'Sharing my daily thoughts and voice recordings 🌧️',
      followersCount: 1240,
      followingCount: 340,
      confessionCount: 12,
      upiId: 'aria@upi',
      links: ['https://aria.medium.com'],
    ),
    const AppUser(
      id: 'author_2',
      displayName: 'Julian K',
      handle: '@julian_k',
      bio: 'Just sharing real stories from my life.',
      followersCount: 412,
      followingCount: 180,
      confessionCount: 5,
      upiId: 'julian@upi',
      links: [],
    ),
    const AppUser(
      id: 'author_3',
      displayName: 'Maya Patel',
      handle: '@maya_writes',
      bio: 'Recording expressive thoughts and stories. Hope you enjoy!',
      followersCount: 2310,
      followingCount: 890,
      confessionCount: 24,
      upiId: 'maya@upi',
      links: ['https://maya.letterdrop.com'],
    ),
    const AppUser(
      id: 'author_4',
      displayName: 'Leo Sterling',
      handle: '@leo_s',
      bio: 'Welcome to my page. Sharing real stories here.',
      followersCount: 95,
      followingCount: 140,
      confessionCount: 2,
      upiId: 'leo@upi',
      links: [],
    ),
  ];

  static List<double> generateWaveform(int count) {
    return List.generate(count, (index) {
      if (index % 5 == 0) return 0.2;
      if (index % 4 == 0) return 0.5;
      if (index % 3 == 0) return 0.8;
      if (index % 2 == 0) return 0.4;
      return 0.6;
    });
  }

  static DateTime _getRelativeDate(int daysBack) {
    return DateTime.now().subtract(Duration(days: daysBack));
  }

  static List<Confession> mockConfessions = [
    Confession(
      id: 'conf_1',
      title: 'I still remember your voice',
      authorId: 'author_1',
      createdAt: _getRelativeDate(0),
      durationString: '3:12',
      durationSeconds: 192,
      waveformData: generateWaveform(35),
      commentsCount: 38,
      isSaved: true,
    ),
    Confession(
      id: 'conf_2',
      title: 'some nights still hurt',
      authorId: 'author_2',
      createdAt: _getRelativeDate(0),
      durationString: '1:45',
      durationSeconds: 105,
      waveformData: generateWaveform(35),
      commentsCount: 12,
      isSaved: false,
    ),
    Confession(
      id: 'conf_3',
      title: 'I never told her this ❤️',
      authorId: 'author_3',
      createdAt: _getRelativeDate(1),
      durationString: '4:20',
      durationSeconds: 260,
      waveformData: generateWaveform(35),
      commentsCount: 84,
      isSaved: true,
    ),
    Confession(
      id: 'conf_4',
      title: 'letters that remained inside drawer',
      authorId: 'author_4',
      createdAt: _getRelativeDate(1),
      durationString: '2:30',
      durationSeconds: 150,
      waveformData: generateWaveform(35),
      commentsCount: 8,
      isSaved: false,
    ),
    Confession(
      id: 'conf_5',
      title: 'why did we say goodbye at the train station?',
      authorId: 'author_1',
      createdAt: _getRelativeDate(3),
      durationString: '5:04',
      durationSeconds: 304,
      waveformData: generateWaveform(35),
      commentsCount: 45,
      isSaved: false,
    ),
    Confession(
      id: 'conf_current_user_1',
      title: 'I saw you in my dream again',
      authorId: 'user_current',
      createdAt: _getRelativeDate(4),
      durationString: '2:15',
      durationSeconds: 135,
      waveformData: generateWaveform(35),
      commentsCount: 3,
      isSaved: false,
    )
  ];

  static Map<String, List<Comment>> mockComments = {
    'conf_1': [
      Comment(
        id: 'comm_1_1',
        confessionId: 'conf_1',
        authorId: 'user_2',
        content: 'This hits so incredibly close to home. I had to close my eyes while listening.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        isAuthor: false,
      ),
      Comment(
        id: 'comm_1_2',
        confessionId: 'conf_1',
        authorId: 'user_3',
        content: 'Thank you for listening... it took me three years to finally voice this ❤️',
        createdAt: DateTime.now().subtract(const Duration(minutes: 8)),
        isAuthor: true, // Original confession author
      ),
      Comment(
        id: 'comm_1_3',
        confessionId: 'conf_1',
        authorId: 'user_4',
        content: 'The background rain matches your pacing beautifully. Timeless poetry.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isAuthor: false,
      ),
    ],
    'conf_2': [
      Comment(
        id: 'comm_2_1',
        confessionId: 'conf_2',
        authorId: 'user_5',
        content: 'Sleepless nights and these whispers are the perfect companion.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isAuthor: false,
      ),
      Comment(
        id: 'comm_2_2',
        confessionId: 'conf_2',
        authorId: 'user_1',
        content: 'I hope sharing this brought you some peace. It sounds like a heavy sigh.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        isAuthor: false,
      ),
    ],
    'conf_3': [
      Comment(
        id: 'comm_3_1',
        confessionId: 'conf_3',
        authorId: 'user_3',
        content: '"I never told her this..." Oh my. First love is such a beautiful scar, isn\'t it?',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isAuthor: false,
      ),
      Comment(
        id: 'comm_3_2',
        confessionId: 'conf_3',
        authorId: 'user_2',
        content: 'Yes, it remains pristine and untouched by time.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        isAuthor: true,
      ),
    ],
    'conf_current_user_1': [
      Comment(
        id: 'comm_cur_1',
        confessionId: 'conf_current_user_1',
        authorId: 'user_3',
        content: 'Dreams are where we keep what we couldn\'t save. Such a warm, poetic recording.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isAuthor: false,
      ),
    ]
  };

  static List<Confession> get last24HoursConfessions {
    final now = DateTime.now();
    return mockConfessions.where((c) => now.difference(c.createdAt).inHours < 24).toList();
  }

  static List<Confession> get followingConfessions {
    return mockConfessions.where((c) => c.authorId != 'user_current').toList();
  }

  static List<Confession> generateManyMockConfessions(int count, {bool forFollowing = false}) {
    final List<String> titles = [
      'I still think about our late night talks',
      'I wish I had the courage to say sorry',
      'To the stranger I met in the coffee shop',
      'Some memories never fade away',
      'I lied to you about my feelings',
      'I am still holding onto your letter',
      'Sometimes I walk past your street',
      'I missed my chance to tell you the truth',
      'I hope you are happy wherever you are',
      'The hardest part was letting you go',
      'Sleepless nights make me remember your smile',
      'I kept the promise we made last autumn',
      'I see your shadow in every crowd',
      'We became strangers with memories',
      'I still play the song you shared with me',
    ];

    return List.generate(count, (index) {
      final userIndex = index % mockUsers.length;
      final user = mockUsers[userIndex];
      final titleIndex = (index + (forFollowing ? 5 : 0)) % titles.length;
      final durationM = 1 + (index % 4);
      final durationS = 10 + (index * 13) % 49;
      
      return Confession(
        id: forFollowing ? 'conf_gen_f_$index' : 'conf_gen_24h_$index',
        title: titles[titleIndex],
        authorId: user.id,
        createdAt: DateTime.now().subtract(Duration(hours: index + 1)),
        durationString: '$durationM:${durationS.toString().padLeft(2, '0')}',
        durationSeconds: durationM * 60 + durationS,
        waveformData: generateWaveform(35),
        commentsCount: 2 + index,
        isSaved: index % 7 == 0,
      );
    });
  }

  static List<AppUser> followersList = [
    mockUsers[0], // Aria
    mockUsers[1], // Julian
    mockUsers[3], // Leo
  ];

  static List<AppUser> followingList = [
    mockUsers[0], // Aria
    mockUsers[2], // Maya
  ];
}
