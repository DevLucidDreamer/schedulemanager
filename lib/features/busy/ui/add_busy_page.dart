import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/auth/providers/auth_providers.dart';
import 'package:schedulemanager/features/busy/data/busy_repository.dart';
import 'package:schedulemanager/features/busy/models/busy_block.dart';
import 'package:schedulemanager/features/busy/providers/busy_providers.dart';
import 'package:uuid/uuid.dart';

class AddBusyPage extends ConsumerStatefulWidget {
  const AddBusyPage({super.key});

  @override
  ConsumerState<AddBusyPage> createState() => _AddBusyPageState();
}

class _AddBusyPageState extends ConsumerState<AddBusyPage> {
  BusyCategory _category = BusyCategory.partTime;
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now().add(const Duration(hours: 2));
  final _formKey = GlobalKey<FormState>();

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _start,
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_start));
    if (time == null) return;
    setState(() {
      _start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (!_start.isBefore(_end)) {
        _end = _start.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEnd() async {
    final date = await showDatePicker(
      context: context,
      firstDate: _start,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _end,
    );
    if (date == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_end));
    if (time == null) return;
    setState(() {
      _end = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      if (!_end.isAfter(_start)) {
        _end = _start.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    final repo = ref.read(busyRepositoryProvider);
    final block = BusyBlock(
      id: const Uuid().v4(),
      userId: userId,
      startAt: _start,
      endAt: _end,
      category: _category,
    );
    await repo.addBusyBlock(block);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('불가능 시간이 추가되었습니다.')),
      );
      ref.read(selectedDateProvider.notifier).state = AppDateUtils.startOfDay(_start);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<BusyCategory>(
              value: _category,
              items: BusyCategory.values
                  .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 16),
            _DateTimeField(
              label: '시작',
              dateTime: _start,
              onTap: _pickStart,
            ),
            const SizedBox(height: 12),
            _DateTimeField(
              label: '끝',
              dateTime: _end,
              onTap: _pickEnd,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: const Text('추가하기'),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({required this.label, required this.dateTime, required this.onTap});

  final String label;
  final DateTime dateTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: InputDecorator(
            decoration: InputDecoration(hintText: label),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${dateTime.year}.${dateTime.month}.${dateTime.day} ${AppDateUtils.formatTime(dateTime)}'),
                const Icon(Icons.edit_calendar_outlined),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
