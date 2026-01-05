import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/auth/providers/auth_providers.dart';
import 'package:schedulemanager/features/busy/models/busy_block.dart';
import 'package:schedulemanager/features/busy/providers/busy_providers.dart';
import 'package:schedulemanager/features/groups/data/group_repository.dart';
import 'package:schedulemanager/features/groups/models/group.dart';

class TimeWindow {
  TimeWindow({required this.start, required this.end});
  final DateTime start;
  final DateTime end;
}

class Recommendation {
  Recommendation({
    required this.date,
    required this.availableCount,
    this.bestWindow,
  });

  final DateTime date;
  final int availableCount;
  final TimeWindow? bestWindow;
}

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(ref.watch(busyRepositoryProvider));
});

final userGroupsProvider = StreamProvider<List<Group>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const Stream.empty();
  return ref.watch(groupRepositoryProvider).watchGroups(userId);
});

final groupDetailProvider = StreamProvider.family<Group, String>((ref, groupId) {
  return ref.watch(groupRepositoryProvider).watchGroup(groupId);
});

final recommendationProvider = FutureProvider.family<List<Recommendation>, Group>((ref, group) async {
  final repo = ref.watch(groupRepositoryProvider);
  final now = AppDateUtils.startOfDay(DateTime.now());
  final rangeEnd = now.add(const Duration(days: 14));
  final busyBlocks = await repo.fetchMemberBusyBlocks(
    memberIds: group.memberIds,
    rangeStart: now,
    rangeEnd: rangeEnd,
  );
  final recommendations = _calculateRecommendations(busyBlocks, now, rangeEnd);
  recommendations.sort((a, b) {
    final scoreDiff = b.availableCount.compareTo(a.availableCount);
    if (scoreDiff != 0) return scoreDiff;
    final aLen = a.bestWindow == null ? 0 : a.bestWindow!.end.difference(a.bestWindow!.start).inMinutes;
    final bLen = b.bestWindow == null ? 0 : b.bestWindow!.end.difference(b.bestWindow!.start).inMinutes;
    return bLen.compareTo(aLen);
  });
  return recommendations.take(5).toList();
});

List<Recommendation> _calculateRecommendations(
  List<BusyBlock> busyBlocks,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final List<Recommendation> results = [];
  for (var day = rangeStart; day.isBefore(rangeEnd); day = day.add(const Duration(days: 1))) {
    final dayStart = AppDateUtils.startOfDay(day);
    final slots = List<bool>.filled(48, true);
    for (final block in busyBlocks) {
      if (!block.overlapsDate(dayStart)) continue;
      final blockStart = block.startAt.isBefore(dayStart) ? dayStart : block.startAt;
      final blockEnd = block.endAt.isAfter(dayStart.add(const Duration(hours: 24)))
          ? dayStart.add(const Duration(hours: 24))
          : block.endAt;
      int startIndex = ((blockStart.difference(dayStart).inMinutes) / 30).floor();
      int endIndex = ((blockEnd.difference(dayStart).inMinutes) / 30).ceil();
      startIndex = startIndex.clamp(0, 47);
      endIndex = endIndex.clamp(0, 48);
      for (int i = startIndex; i < endIndex; i++) {
        slots[i] = false;
      }
    }

    final availableCount = slots.where((s) => s).length;
    TimeWindow? best;
    int currentStart = -1;
    int bestLength = 0;
    for (int i = 0; i <= slots.length; i++) {
      final available = i < slots.length ? slots[i] : false;
      if (available && currentStart == -1) {
        currentStart = i;
      } else if (!available && currentStart != -1) {
        final length = i - currentStart;
        if (length > bestLength) {
          bestLength = length;
          best = TimeWindow(
            start: dayStart.add(Duration(minutes: currentStart * 30)),
            end: dayStart.add(Duration(minutes: i * 30)),
          );
        }
        currentStart = -1;
      }
    }

    results.add(Recommendation(date: dayStart, availableCount: availableCount, bestWindow: best));
  }
  return results;
}
