import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The container environment should be set to Asia/Seoul to honor the
  // local-time based scheduling. All DateTime usage in this app assumes the
  // device timezone is Asia/Seoul.
  runApp(const ProviderScope(child: ScheduleManagerApp()));
}
