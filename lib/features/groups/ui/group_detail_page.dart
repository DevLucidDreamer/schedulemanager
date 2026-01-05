import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/groups/providers/group_providers.dart';
import 'package:schedulemanager/features/groups/ui/widgets/recommendation_card.dart';

class GroupDetailPage extends ConsumerWidget {
  const GroupDetailPage({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(groupDetailProvider(groupId));
    return Scaffold(
      appBar: AppBar(),
      body: groupAsync.when(
        data: (group) {
          final recommendations = ref.watch(recommendationProvider(group));
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(group.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('초대 코드: ${group.inviteCode}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: group.inviteCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('초대코드가 복사되었습니다.')),
                      );
                    },
                  )
                ],
              ),
              Text('멤버 ${group.memberIds.length}명', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('추천 일정 (14일)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              recommendations.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Text('추천 가능한 일정이 없습니다. 불가능 시간을 추가해 주세요.');
                  }
                  return Column(
                    children: list
                        .map((rec) => RecommendationCard(
                              date: AppDateUtils.formatDate(rec.date),
                              availableCount: rec.availableCount,
                              bestWindow: rec.bestWindow,
                            ))
                        .toList(),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, __) => Text('추천을 가져오지 못했습니다: $e'),
              )
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('그룹을 불러오지 못했습니다: $e')),
      ),
    );
  }
}
