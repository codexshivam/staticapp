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
  });

  String get initials {
    if (displayName.isEmpty) return '??';
    final parts = displayName.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return displayName.substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }
}
