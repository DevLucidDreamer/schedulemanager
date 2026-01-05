import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory Group.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Group(
      id: doc.id,
      name: data['name'] as String,
      inviteCode: data['inviteCode'] as String,
      memberIds: List<String>.from(data['memberIds'] as List<dynamic>),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'inviteCode': inviteCode,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
