import 'package:schedulemanager/core/utils/date_utils.dart';

enum BusyCategory { partTime, classTime, appointment, other }

extension BusyCategoryX on BusyCategory {
  String get label {
    switch (this) {
      case BusyCategory.partTime:
        return '알바';
      case BusyCategory.classTime:
        return '수업';
      case BusyCategory.appointment:
        return '선약';
      case BusyCategory.other:
        return '기타';
    }
  }

  static BusyCategory fromLabel(String label) {
    return BusyCategory.values.firstWhere(
      (c) => c.label == label,
      orElse: () => BusyCategory.other,
    );
  }
}

class BusyBlock {
  BusyBlock({
    required this.id,
    required this.userId,
    required this.startAt,
    required this.endAt,
    required this.category,
  });

  final String id;
  final String userId;
  final DateTime startAt;
  final DateTime endAt;
  final BusyCategory category;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'category': category.name,
    };
  }

  bool overlapsDate(DateTime date) {
    final startOfDay = AppDateUtils.startOfDay(date);
    final endOfDay = AppDateUtils.endOfDay(date);
    return startAt.isBefore(endOfDay) && endAt.isAfter(startOfDay);
  }
}
