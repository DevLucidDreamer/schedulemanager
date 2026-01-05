import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/busy/ui/add_busy_page.dart';
import 'features/busy/ui/home_calendar_page.dart';
import 'features/groups/ui/groups_page.dart';

class ScheduleManagerApp extends ConsumerWidget {
  const ScheduleManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authInit = ref.watch(authInitializerProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Schedule Manager',
      theme: buildAppTheme(),
      home: authInit.when(
        data: (_) => const _RootNavigation(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, __) => Scaffold(
          body: Center(child: Text('Auth init failed: $e')),
        ),
      ),
    );
  }
}

class _RootNavigation extends StatefulWidget {
  const _RootNavigation();

  @override
  State<_RootNavigation> createState() => _RootNavigationState();
}

class _RootNavigationState extends State<_RootNavigation> {
  int _index = 0;

  final _pages = const [
    HomeCalendarPage(),
    AddBusyPage(),
    GroupsPage(),
  ];

  final _titles = const ['홈', '불가능 시간 추가', '그룹'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
      ),
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calendar_today), label: '홈'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: '추가'),
          NavigationDestination(icon: Icon(Icons.group_outlined), label: '그룹'),
        ],
      ),
    );
  }
}
