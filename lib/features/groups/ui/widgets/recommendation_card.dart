import 'package:flutter/material.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/groups/providers/group_providers.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({super.key, required this.date, required this.availableCount, this.bestWindow});

  final String date;
  final int availableCount;
  final TimeWindow? bestWindow;

  @override
  Widget build(BuildContext context) {
    final bestLabel = bestWindow == null
        ? '가능 시간 없음'
        : '${AppDateUtils.formatTime(bestWindow!.start)} ~ ${AppDateUtils.formatTime(bestWindow!.end)}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(date),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('총 가능 슬롯: $availableCount'),
            Text('최장 연속 가능: $bestLabel'),
          ],
        ),
      ),
    );
  }
}
