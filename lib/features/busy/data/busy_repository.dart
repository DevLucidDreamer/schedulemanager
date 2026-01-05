import 'dart:async';
import '../models/busy_block.dart';

class BusyRepository {
  BusyRepository();

  final List<BusyBlock> _busyBlocks = [];
  late final StreamController<List<BusyBlock>> _controller =
      StreamController<List<BusyBlock>>.broadcast(onListen: _emit);

  void _emit() {
    _controller.add(List.unmodifiable(_busyBlocks));
  }

  Stream<List<BusyBlock>> watchBusyBlocks(String userId) {
    return _controller.stream.map(
      (blocks) => blocks
          .where((block) => block.userId == userId)
          .toList()
        ..sort((a, b) => a.startAt.compareTo(b.startAt)),
    );
  }

  Future<void> addBusyBlock(BusyBlock block) async {
    _busyBlocks.add(block);
    _emit();
  }

  Future<void> deleteBusyBlock(String id) async {
    _busyBlocks.removeWhere((element) => element.id == id);
    _emit();
  }

  Future<List<BusyBlock>> fetchBusyBlocksForUsers({
    required List<String> userIds,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) async {
    if (userIds.isEmpty) return [];
    return _busyBlocks
        .where((block) => userIds.contains(block.userId))
        .where((block) =>
            block.endAt.isAfter(rangeStart) && block.startAt.isBefore(rangeEnd))
        .toList();
  }
}
