class AppUser {
  final String id;
  final String displayName;
  final String handle;
  final String bio;
  final int followersCount;
  final int followingCount;
  final int confessionCount;
  final String upiId;
  final List<String> links;
  final String lastPlaybackDate;
  final int dailyPlaybackCount;
  final List<String> savedConfessionIds;
  final List<String> followingIds;
  final List<String> followerIds;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.handle,
    required this.bio,
    required this.followersCount,
    required this.followingCount,
    required this.confessionCount,
    required this.upiId,
    required this.links,
    this.lastPlaybackDate = '',
    this.dailyPlaybackCount = 0,
    this.savedConfessionIds = const [],
    this.followingIds = const [],
    this.followerIds = const [],
  });

  String get initials {
    if (displayName.isEmpty) return '??';
    final parts = displayName.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return displayName.substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  bool isFollowing(String userId) => followingIds.contains(userId);
  bool isFollowedBy(String userId) => followerIds.contains(userId);

  AppUser copyWith({
    String? id,
    String? displayName,
    String? handle,
    String? bio,
    int? followersCount,
    int? followingCount,
    int? confessionCount,
    String? upiId,
    List<String>? links,
    String? lastPlaybackDate,
    int? dailyPlaybackCount,
    List<String>? savedConfessionIds,
    List<String>? followingIds,
    List<String>? followerIds,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      bio: bio ?? this.bio,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      confessionCount: confessionCount ?? this.confessionCount,
      upiId: upiId ?? this.upiId,
      links: links ?? this.links,
      lastPlaybackDate: lastPlaybackDate ?? this.lastPlaybackDate,
      dailyPlaybackCount: dailyPlaybackCount ?? this.dailyPlaybackCount,
      savedConfessionIds: savedConfessionIds ?? this.savedConfessionIds,
      followingIds: followingIds ?? this.followingIds,
      followerIds: followerIds ?? this.followerIds,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['\$id'] ?? json['id'] ?? '',
      displayName: json['displayName'] ?? '',
      handle: json['handle'] ?? '',
      bio: json['bio'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      confessionCount: json['confessionCount'] ?? 0,
      upiId: json['upiId'] ?? '',
      links: List<String>.from(json['links'] ?? []),
      lastPlaybackDate: json['lastPlaybackDate'] ?? '',
      dailyPlaybackCount: json['dailyPlaybackCount'] ?? 0,
      savedConfessionIds: List<String>.from(json['savedConfessionIds'] ?? []),
      followingIds: List<String>.from(json['followingIds'] ?? []),
      followerIds: List<String>.from(json['followerIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'handle': handle,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'confessionCount': confessionCount,
      'upiId': upiId,
      'links': links,
      'lastPlaybackDate': lastPlaybackDate,
      'dailyPlaybackCount': dailyPlaybackCount,
      'savedConfessionIds': savedConfessionIds,
      'followingIds': followingIds,
      'followerIds': followerIds,
    };
  }
}
