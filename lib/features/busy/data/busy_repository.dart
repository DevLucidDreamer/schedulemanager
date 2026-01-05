import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/busy_block.dart';

class BusyRepository {
  BusyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('busyBlocks');

  Stream<List<BusyBlock>> watchBusyBlocks(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('startAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BusyBlock.fromDoc(doc)).toList());
  }

  Future<void> addBusyBlock(BusyBlock block) {
    return _collection.add(block.toMap());
  }

  Future<void> deleteBusyBlock(String id) {
    return _collection.doc(id).delete();
  }

  Future<List<BusyBlock>> fetchBusyBlocksForUsers({
    required List<String> userIds,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    if (userIds.isEmpty) return [];
    final List<BusyBlock> results = [];
    const chunkSize = 10;
    for (var i = 0; i < userIds.length; i += chunkSize) {
      final chunk = userIds.skip(i).take(chunkSize).toList();
      final query = await _collection
          .where('userId', whereIn: chunk)
          .orderBy('startAt')
          .startAt([Timestamp.fromDate(rangeStart.subtract(const Duration(days: 1)))])
          .get();
      for (final doc in query.docs) {
        final block = BusyBlock.fromDoc(doc);
        if (block.endAt.isAfter(rangeStart) && block.startAt.isBefore(rangeEnd)) {
          results.add(block);
        }
      }
    }
    return results;
  }
}
