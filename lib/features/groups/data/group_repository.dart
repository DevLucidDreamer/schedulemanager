import 'dart:async';
import 'dart:math';
import 'package:schedulemanager/features/busy/data/busy_repository.dart';
import 'package:schedulemanager/features/busy/models/busy_block.dart';
import 'package:schedulemanager/features/groups/models/group.dart';

class GroupRepository {
  GroupRepository(this._busyRepository);

  final BusyRepository _busyRepository;
  final List<Group> _groups = [];
  late final StreamController<List<Group>> _controller =
      StreamController<List<Group>>.broadcast(onListen: _emit);

  void _emit() {
    _controller.add(List.unmodifiable(_groups));
  }

  Stream<List<Group>> watchGroups(String userId) {
    return _controller.stream.map(
      (groups) => groups
          .where((group) => group.memberIds.contains(userId))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  Stream<Group> watchGroup(String groupId) {
    return _controller.stream.map(
      (groups) => groups.firstWhere((group) => group.id == groupId),
    );
  }

  Future<Group> createGroup({required String name, required String ownerId}) async {
    final invite = _generateUniqueCode();
    final group = Group(
      id: _generateId(),
      name: name,
      inviteCode: invite,
      memberIds: [ownerId],
      createdAt: DateTime.now(),
    );
    _groups.add(group);
    _emit();
    return group;
  }

  Future<Group?> joinGroup({required String code, required String userId}) async {
    final group = _groups.cast<Group?>().firstWhere(
          (g) => g?.inviteCode.toUpperCase() == code.toUpperCase(),
          orElse: () => null,
        );
    if (group == null) return null;
    if (!group.memberIds.contains(userId)) {
      group.memberIds.add(userId);
      _emit();
    }
    return group;
  }

  String _generateUniqueCode() {
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    String code;
    bool exists = true;
    do {
      code = List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
      exists = _groups.any((g) => g.inviteCode == code);
    } while (exists);
    return code;
  }

  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

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
