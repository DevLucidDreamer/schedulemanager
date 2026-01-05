class Group {
  Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.memberIds,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String inviteCode;
  final List<String> memberIds;
  final DateTime createdAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'inviteCode': inviteCode,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
