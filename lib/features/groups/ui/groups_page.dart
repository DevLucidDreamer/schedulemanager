import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/group_providers.dart';
import 'join_group_page.dart';
import 'group_detail_page.dart';

class GroupsPage extends ConsumerWidget {
  const GroupsPage({super.key});

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('그룹 만들기'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(hintText: '그룹 이름'),
            validator: (value) => value == null || value.isEmpty ? '이름을 입력하세요' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('취소')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('생성'),
          )
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final repo = ref.read(groupRepositoryProvider);
    await repo.createGroup(name: result, ownerId: userId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(userGroupsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _createGroup(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('그룹 생성'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const JoinGroupPage()),
                    );
                  },
                  icon: const Icon(Icons.link),
                  label: const Text('초대 코드 입력'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: groupsAsync.when(
            data: (groups) {
              if (groups.isEmpty) {
                return const Center(child: Text('참여한 그룹이 없습니다. 새 그룹을 만들어보세요.'));
              }
              return ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ListTile(
                      title: Text(group.name),
                      subtitle: Text('멤버 ${group.memberIds.length}명 · 코드 ${group.inviteCode}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => GroupDetailPage(groupId: group.id)),
                        );
                      },
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('그룹을 불러오지 못했습니다: $e')),
          ),
        )
      ],
    );
  }
}
