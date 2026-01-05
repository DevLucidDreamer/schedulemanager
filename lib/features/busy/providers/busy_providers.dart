import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/auth/providers/auth_providers.dart';
import 'package:schedulemanager/features/busy/data/busy_repository.dart';
import 'package:schedulemanager/features/busy/models/busy_block.dart';

final busyRepositoryProvider = Provider<BusyRepository>((ref) {
  return BusyRepository();
});

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return AppDateUtils.startOfDay(DateTime.now());
});

final busyBlocksProvider = StreamProvider<List<BusyBlock>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return const Stream.empty();
  }
  return ref.watch(busyRepositoryProvider).watchBusyBlocks(userId);
});

final busyForSelectedDateProvider = Provider<List<BusyBlock>>((ref) {
  final date = ref.watch(selectedDateProvider);
  final busyBlocks = ref.watch(busyBlocksProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <BusyBlock>[],
      );
  final filtered = busyBlocks.where((b) => b.overlapsDate(date)).toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
  return filtered;
});

final busyCountByDateProvider = Provider<Map<DateTime, int>>((ref) {
  final busyBlocks = ref.watch(busyBlocksProvider).maybeWhen(
        data: (data) => data,
        orElse: () => <BusyBlock>[],
      );
  final Map<DateTime, int> counts = {};
  for (final block in busyBlocks) {
    DateTime cursor = AppDateUtils.startOfDay(block.startAt);
    final end = AppDateUtils.startOfDay(block.endAt);
    while (!cursor.isAfter(end)) {
      if (block.overlapsDate(cursor)) {
        counts[cursor] = (counts[cursor] ?? 0) + 1;
      }
      cursor = cursor.add(const Duration(days: 1));
    }
  }
  return counts;
});
