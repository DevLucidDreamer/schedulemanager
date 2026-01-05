import 'package:flutter/material.dart';
import 'package:schedulemanager/core/utils/date_utils.dart';
import 'package:schedulemanager/features/busy/models/busy_block.dart';

class BusyBlockTile extends StatelessWidget {
  const BusyBlockTile({super.key, required this.block, this.onDelete});

  final BusyBlock block;
  final VoidCallback? onDelete;

  Color _categoryColor(BusyCategory category) {
    switch (category) {
      case BusyCategory.partTime:
        return Colors.orange.shade400;
      case BusyCategory.classTime:
        return Colors.blue.shade400;
      case BusyCategory.appointment:
        return Colors.green.shade400;
      case BusyCategory.other:
        return Colors.purple.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _categoryColor(block.category),
          child: Text(
            block.category.label.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(block.category.label),
        subtitle: Text(AppDateUtils.formatRange(block.startAt, block.endAt)),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
              )
            : null,
      ),
    );
  }
}
