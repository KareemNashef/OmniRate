class Friend {
  final String id;
  final String name;
  final FriendStatus status;

  Friend({
    required this.id,
    required this.name,
    required this.status,
  });
}

enum FriendStatus { accepted, pending, requested }