import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:schedulemanager/features/busy/data/busy_repository.dart';
import 'package:schedulemanager/features/busy/models/busy_block.dart';
import 'package:schedulemanager/features/groups/models/group.dart';

class GroupRepository {
  GroupRepository(this._firestore, this._busyRepository);

  final FirebaseFirestore _firestore;
  final BusyRepository _busyRepository;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('groups');

  Stream<List<Group>> watchGroups(String userId) {
    return _collection
        .where('memberIds', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Group.fromDoc).toList());
  }

  Stream<Group> watchGroup(String groupId) {
    return _collection.doc(groupId).snapshots().map((doc) => Group.fromDoc(doc));
  }

  Future<Group> createGroup({required String name, required String ownerId}) async {
    final invite = await _generateUniqueCode();
    final doc = await _collection.add({
      'name': name,
      'inviteCode': invite,
      'memberIds': [ownerId],
      'createdAt': Timestamp.now(),
    });
    final snapshot = await doc.get();
    return Group.fromDoc(snapshot);
  }

  Future<Group?> joinGroup({required String code, required String userId}) async {
    final query = await _collection.where('inviteCode', isEqualTo: code).limit(1).get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    final members = List<String>.from(doc.data()['memberIds'] as List<dynamic>);
    if (!members.contains(userId)) {
      members.add(userId);
      await doc.reference.update({'memberIds': members});
    }
    final snapshot = await doc.reference.get();
    return Group.fromDoc(snapshot);
  }

  Future<String> _generateUniqueCode() async {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    String code;
    bool exists = true;
    do {
      code = List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
      final query = await _collection.where('inviteCode', isEqualTo: code).limit(1).get();
      exists = query.docs.isNotEmpty;
    } while (exists);
    return code;
  }

  Future<List<BusyBlock>> fetchMemberBusyBlocks({
    required List<String> memberIds,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    return _busyRepository.fetchBusyBlocksForUsers(
      userIds: memberIds,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
    );
  }
}
