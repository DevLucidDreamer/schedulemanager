import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_providers.dart';
import '../providers/group_providers.dart';

class JoinGroupPage extends ConsumerStatefulWidget {
  const JoinGroupPage({super.key});

  @override
  ConsumerState<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends ConsumerState<JoinGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  bool _loading = false;

  Future<void> _join() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _loading = true);
    final repo = ref.read(groupRepositoryProvider);
    final group = await repo.joinGroup(code: _codeController.text.trim().toUpperCase(), userId: user.uid);
    setState(() => _loading = false);
    if (group == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('코드가 올바르지 않습니다.')));
      return;
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${group!.name} 그룹에 참여했습니다.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('초대 코드 입력')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('6자리 초대코드를 입력하세요.'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: '초대 코드'),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => value == null || value.length != 6 ? '6자리 코드를 입력하세요' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _join,
                  child: _loading ? const CircularProgressIndicator() : const Text('참여하기'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
