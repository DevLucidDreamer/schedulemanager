import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/busy/providers/busy_providers.dart';
import 'package:schedulemanager/features/busy/ui/widgets/busy_block_tile.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeCalendarPage extends ConsumerWidget {
  const HomeCalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final busyForDate = ref.watch(busyForSelectedDateProvider);
    final busyCount = ref.watch(busyCountByDateProvider);

    return Column(
      children: [
        TableCalendar(
          focusedDay: selectedDate,
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          locale: 'ko_KR',
          calendarFormat: CalendarFormat.month,
          selectedDayPredicate: (day) => AppDateUtils.isSameDay(day, selectedDate),
          onDaySelected: (selected, _) {
            ref.read(selectedDateProvider.notifier).state = AppDateUtils.startOfDay(selected);
          },
          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
          calendarStyle: const CalendarStyle(outsideDaysVisible: false),
          eventLoader: (day) {
            final key = AppDateUtils.startOfDay(day);
            final count = busyCount[key] ?? 0;
            return List.filled(count, 'busy');
          },
          calendarBuilders: CalendarBuilders(markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            return Positioned(
              right: 6,
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Text('${events.length}', style: const TextStyle(fontSize: 12)),
              ),
            );
          }),
        ),
        const Divider(),
        Expanded(
          child: busyForDate.isEmpty
              ? const Center(child: Text('선택한 날짜에 등록된 불가능 시간이 없습니다.'))
              : ListView.builder(
                  itemCount: busyForDate.length,
                  itemBuilder: (context, index) {
                    final block = busyForDate[index];
                    return BusyBlockTile(block: block);
                  },
                ),
        ),
      ],
    );
  }
}
