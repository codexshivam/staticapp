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

  static String _getRelativeDateStr(int daysBack) {
    final date = DateTime.now().subtract(Duration(days: daysBack));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static List<Confession> mockConfessions = [
    Confession(
      id: 'conf_1',
      title: 'I still remember your voice',
      authorName: 'Aria Mitchell',
      authorHandle: '@aria_m',
      authorId: 'author_1',
      timestamp: '10:42 PM',
      durationString: '3:12',
      durationSeconds: 192,
      waveformData: generateWaveform(35),
      likesCount: 542,
      commentsCount: 38,
      isSaved: true,
      dateText: _getRelativeDateStr(0), // Today
    ),
    Confession(
      id: 'conf_2',
      title: 'some nights still hurt',
      authorName: 'Julian K',
      authorHandle: '@julian_k',
      authorId: 'author_2',
      timestamp: '2:15 AM',
      durationString: '1:45',
      durationSeconds: 105,
      waveformData: generateWaveform(35),
      likesCount: 184,
      commentsCount: 12,
      isSaved: false,
      dateText: _getRelativeDateStr(0), // Today
    ),
    Confession(
      id: 'conf_3',
      title: 'I never told her this ❤️',
      authorName: 'Maya Patel',
      authorHandle: '@maya_writes',
      authorId: 'author_3',
      timestamp: 'Yesterday',
      durationString: '4:20',
      durationSeconds: 260,
      waveformData: generateWaveform(35),
      likesCount: 1204,
      commentsCount: 84,
      isSaved: true,
      dateText: _getRelativeDateStr(1), // Yesterday
    ),
    Confession(
      id: 'conf_4',
      title: 'letters that remained inside drawer',
      authorName: 'Leo Sterling',
      authorHandle: '@leo_s',
      authorId: 'author_4',
      timestamp: 'Yesterday',
      durationString: '2:30',
      durationSeconds: 150,
      waveformData: generateWaveform(35),
      likesCount: 96,
      commentsCount: 8,
      isSaved: false,
      dateText: _getRelativeDateStr(1), // Yesterday
    ),
    Confession(
      id: 'conf_5',
      title: 'why did we say goodbye at the train station?',
      authorName: 'Aria Mitchell',
      authorHandle: '@aria_m',
      authorId: 'author_1',
      timestamp: '3 days ago',
      durationString: '5:04',
      durationSeconds: 304,
      waveformData: generateWaveform(35),
      likesCount: 832,
      commentsCount: 45,
      isSaved: false,
      dateText: _getRelativeDateStr(3),
    ),
    Confession(
      id: 'conf_current_user_1',
      title: 'I saw you in my dream again',
      authorName: 'Shivam Yadav',
      authorHandle: '@shivamyadav',
      authorId: 'user_current',
      timestamp: '4 days ago',
      durationString: '2:15',
      durationSeconds: 135,
      waveformData: generateWaveform(35),
      likesCount: 34,
      commentsCount: 3,
      isSaved: false,
      dateText: _getRelativeDateStr(4),
    )
  ];

  static Map<String, List<Comment>> mockComments = {
    'conf_1': [
      const Comment(
        id: 'comm_1_1',
        confessionId: 'conf_1',
        authorId: 'user_2',
        authorName: 'Maya Patel',
        authorAvatar: 'MP',
        content: 'This hits so incredibly close to home. I had to close my eyes while listening.',
        timestamp: '10m ago',
        isAuthor: false,
      ),
      const Comment(
        id: 'comm_1_2',
        confessionId: 'conf_1',
        authorId: 'user_3',
        authorName: 'Aria Mitchell',
        authorAvatar: 'AM',
        content: 'Thank you for listening... it took me three years to finally voice this ❤️',
        timestamp: '8m ago',
        isAuthor: true, // Original confession author
      ),
      const Comment(
        id: 'comm_1_3',
        confessionId: 'conf_1',
        authorId: 'user_4',
        authorName: 'Julian K',
        authorAvatar: 'JK',
        content: 'The background rain matches your pacing beautifully. Timeless poetry.',
        timestamp: '5m ago',
        isAuthor: false,
      ),
    ],
    'conf_2': [
      const Comment(
        id: 'comm_2_1',
        confessionId: 'conf_2',
        authorId: 'user_5',
        authorName: 'Leo Sterling',
        authorAvatar: 'LS',
        content: 'Sleepless nights and these whispers are the perfect companion.',
        timestamp: '1h ago',
        isAuthor: false,
      ),
      const Comment(
        id: 'comm_2_2',
        confessionId: 'conf_2',
        authorId: 'user_1',
        authorName: 'Shivam Yadav',
        authorAvatar: 'SY',
        content: 'I hope sharing this brought you some peace. It sounds like a heavy sigh.',
        timestamp: '45m ago',
        isAuthor: false,
      ),
    ],
    'conf_3': [
      const Comment(
        id: 'comm_3_1',
        confessionId: 'conf_3',
        authorId: 'user_3',
        authorName: 'Aria Mitchell',
        authorAvatar: 'AM',
        content: '"I never told her this..." Oh my. First love is such a beautiful scar, isn\'t it?',
        timestamp: '2h ago',
        isAuthor: false,
      ),
      const Comment(
        id: 'comm_3_2',
        confessionId: 'conf_3',
        authorId: 'user_2',
        authorName: 'Maya Patel',
        authorAvatar: 'MP',
        content: 'Yes, it remains pristine and untouched by time.',
        timestamp: '1h ago',
        isAuthor: true,
      ),
    ],
    'conf_current_user_1': [
      const Comment(
        id: 'comm_cur_1',
        confessionId: 'conf_current_user_1',
        authorId: 'user_3',
        authorName: 'Aria Mitchell',
        authorAvatar: 'AM',
        content: 'Dreams are where we keep what we couldn\'t save. Such a warm, poetic recording.',
        timestamp: '1d ago',
        isAuthor: false,
      ),
    ]
  };

  static List<Confession> get last24HoursConfessions {
    return mockConfessions.where((c) => c.dateText == _getRelativeDateStr(0)).toList();
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
        authorName: user.displayName,
        authorHandle: user.handle,
        authorId: user.id,
        timestamp: '${index + 1}h ago',
        durationString: '$durationM:${durationS.toString().padLeft(2, '0')}',
        durationSeconds: durationM * 60 + durationS,
        waveformData: generateWaveform(35),
        likesCount: 10 + index * 3,
        commentsCount: 2 + index,
        isSaved: index % 7 == 0,
        dateText: _getRelativeDateStr(0),
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
