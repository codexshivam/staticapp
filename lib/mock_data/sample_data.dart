import '../models/user.dart';
import '../models/confession.dart';
import '../models/comment.dart';

class SampleData {
  SampleData._();

  // Active Current User
  static AppUser currentUser = const AppUser(
    id: 'user_current',
    displayName: 'Shivam Yadav',
    handle: '@shivamyadav',
    bio: 'collecting whispers in the dark • writing letters I will never mail...',
    followersCount: 148,
    followingCount: 92,
    confessionCount: 3,
    upiId: 'shivam@upi',
    links: [
      'https://shivam.dev/diary',
      'https://instagram.com/silent_letters',
    ],
  );

  // Other Platform Authors
  static List<AppUser> mockUsers = [
    const AppUser(
      id: 'author_1',
      displayName: 'Aria Mitchell',
      handle: '@aria_m',
      bio: 'some feelings are too heavy for words... listening to late night rain 🌧️',
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
      bio: 'capturing the quiet echoes of a summer that slipped away.',
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
      bio: 'if you are listening... I hope you recognize your name.',
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
      bio: 'the heart remembers what the mind tries to forget.',
      followersCount: 95,
      followingCount: 140,
      confessionCount: 2,
      upiId: 'leo@upi',
      links: [],
    ),
  ];

  // Helper Waveform generator
  static List<double> generateWaveform(int count) {
    return List.generate(count, (index) {
      if (index % 5 == 0) return 0.2;
      if (index % 4 == 0) return 0.5;
      if (index % 3 == 0) return 0.8;
      if (index % 2 == 0) return 0.4;
      return 0.6;
    });
  }

  // Pre-configured Mock Confessions
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
      dateText: '2026-05-12', // Today
      tags: ['Late Night', 'Regrets', 'Rainy Days'],
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
      dateText: '2026-05-12', // Today
      tags: ['Memory', 'Unrequited', 'Sadness'],
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
      dateText: '2026-05-11', // Yesterday
      tags: ['Unsaid', 'Confession', 'First Love'],
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
      dateText: '2026-05-11', // Yesterday
      tags: ['Unsaid', 'Nostalgia'],
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
      dateText: '2026-05-09',
      tags: ['Farewells', 'Memory', 'Late Night'],
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
      dateText: '2026-05-08',
      tags: ['Dreams', 'Nocturnal'],
    )
  ];

  // Map of Comments for individual Confessions
  static Map<String, List<Comment>> mockComments = {
    'conf_1': [
      const Comment(
        id: 'comm_1_1',
        authorName: 'Maya Patel',
        authorAvatar: 'MP',
        content: 'This hits so incredibly close to home. I had to close my eyes while listening.',
        timestamp: '10m ago',
        isAuthor: false,
      ),
      const Comment(
        id: 'comm_1_2',
        authorName: 'Aria Mitchell',
        authorAvatar: 'AM',
        content: 'Thank you for listening... it took me three years to finally voice this ❤️',
        timestamp: '8m ago',
        isAuthor: true, // Original confession author
      ),
      const Comment(
        id: 'comm_1_3',
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
        authorName: 'Leo Sterling',
        authorAvatar: 'LS',
        content: 'Sleepless nights and these whispers are the perfect companion.',
        timestamp: '1h ago',
        isAuthor: false,
      ),
      const Comment(
        id: 'comm_2_2',
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
        authorName: 'Aria Mitchell',
        authorAvatar: 'AM',
        content: '"I never told her this..." Oh my. First love is such a beautiful scar, isn\'t it?',
        timestamp: '2h ago',
        isAuthor: false,
      ),
      const Comment(
        id: 'comm_3_2',
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
        authorName: 'Aria Mitchell',
        authorAvatar: 'AM',
        content: 'Dreams are where we keep what we couldn\'t save. Such a warm, poetic recording.',
        timestamp: '1d ago',
        isAuthor: false,
      ),
    ]
  };

  // Section getters for Home Screen
  static List<Confession> get last24HoursConfessions {
    // Return confessions with dateText '2026-05-12' (Aria and Julian)
    return mockConfessions.where((c) => c.dateText == '2026-05-12').toList();
  }

  static List<Confession> get followingConfessions {
    // Return confessions from people we follow (Aria, Julian, Maya)
    return mockConfessions.where((c) => c.authorId != 'user_current').toList();
  }

  // Dynamic user list representation (Followers / Following)
  static List<AppUser> get followersList {
    return [
      mockUsers[0], // Aria
      mockUsers[1], // Julian
      mockUsers[3], // Leo
    ];
  }

  static List<AppUser> get followingList {
    return [
      mockUsers[0], // Aria
      mockUsers[2], // Maya
    ];
  }
}
